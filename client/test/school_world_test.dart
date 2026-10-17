import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/content/content_repository.dart';

/// M6 (seção 7): o mapa livre vem do conteúdo — estes testes garantem que
/// o `school.json` descreve um mapa coerente antes de qualquer tela usar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('todo terreno cabe inteiro dentro do mundo', () async {
    final school = (await ContentRepository.load()).school;
    final half = school.world.lotSize / 2;
    for (final s in school.spaces) {
      expect(s.x - half, greaterThanOrEqualTo(0), reason: s.id);
      expect(s.y - half, greaterThanOrEqualTo(0), reason: s.id);
      expect(s.x + half, lessThanOrEqualTo(school.world.width), reason: s.id);
      expect(s.y + half, lessThanOrEqualTo(school.world.height), reason: s.id);
    }
  });

  test('RM-06: cada espaço fica na região da própria série, e há uma região por série', () async {
    final school = (await ContentRepository.load()).school;
    expect(school.regions.map((r) => r.grade).toSet(), {
      for (var g = 0; g < school.grades.length; g++) g,
    });
    for (final s in school.spaces) {
      final region = school.regions.firstWhere((r) => r.grade == s.grade);
      expect(region.contains(s.x, s.y), isTrue, reason: s.id);
    }
  });

  test('RM-05: terrenos fixos não se sobrepõem', () async {
    final school = (await ContentRepository.load()).school;
    final size = school.world.lotSize;
    for (var i = 0; i < school.spaces.length; i++) {
      for (var j = i + 1; j < school.spaces.length; j++) {
        final a = school.spaces[i], b = school.spaces[j];
        final apart = (a.x - b.x).abs() >= size || (a.y - b.y).abs() >= size;
        expect(apart, isTrue, reason: '${a.id} x ${b.id}');
      }
    }
  });

  test(
    'o mundo é maior que a tela nos dois eixos (mapa livre, RM-01)',
    () async {
      final world = (await ContentRepository.load()).school.world;
      // Celular em pé de referência: 360 × 800 dp.
      expect(world.width, greaterThan(360 * 2));
      expect(world.height, greaterThan(800 * 2));
    },
  );

  test('RM-07: bichinhos de cada região existem no conteúdo', () async {
    final content = await ContentRepository.load();
    for (final r in content.school.regions) {
      expect(r.animals, isNotEmpty, reason: 'região ${r.grade}');
      for (final id in r.animals) {
        expect(content.items.containsKey(id), isTrue, reason: id);
      }
    }
  });
}
