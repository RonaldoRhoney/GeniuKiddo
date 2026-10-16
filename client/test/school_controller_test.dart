import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genius_kiddo/content/content_repository.dart';
import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/features/school/school_controller.dart';
import 'package:genius_kiddo/features/trail/trail_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> build({
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final p = await SharedPreferences.getInstance();
    final content = await ContentRepository.load();
    final c = ProviderContainer(
      overrides: [
        persistenceServiceProvider.overrideWithValue(PersistenceService(p)),
        contentRepositoryProvider.overrideWithValue(content),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  SchoolController ctrl(ProviderContainer c) =>
      c.read(schoolControllerProvider.notifier);
  SchoolState st(ProviderContainer c) => c.read(schoolControllerProvider);

  test(
    'Anexo B: começa com 3 ⭐, Sala no nível 1 e série ainda não escolhida',
    () async {
      final c = await build();
      expect(st(c).stars, 3);
      expect(st(c).levelOf('sala'), 1);
      expect(st(c).grade, isNull);
      expect(ctrl(c).kids, 3); // 2 + soma dos níveis (1)
    },
  );

  test('seção 6.5: construir custa 3, nível 2 custa 6, nível 3 custa 10; sem estrela não gasta', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);

    expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);
    expect(st(c).stars, 0);
    expect(st(c).levelOf('horta'), 1);

    // Sem estrelas: nada muda.
    expect(await ctrl(c).buildOrUpgrade('atelie'), isFalse);
    expect(st(c).levelOf('atelie'), 0);

    expect(ctrl(c).costFor('horta'), 6);
    for (var i = 0; i < 2; i++) {
      await ctrl(c).completeLesson();
    }
    expect(st(c).stars, 6);
    expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);
    expect(ctrl(c).costFor('horta'), 10);
    for (var i = 0; i < 4; i++) {
      await ctrl(c).completeLesson();
    }
    expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);
    expect(st(c).levelOf('horta'), 3);
    expect(ctrl(c).costFor('horta'), isNull); // no máximo
    expect(await ctrl(c).buildOrUpgrade('horta'), isFalse);
  });

  test('seção 6.3: espaço de série futura não pode ser construído', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    for (var i = 0; i < 3; i++) {
      await ctrl(c).completeLesson();
    }
    expect(await ctrl(c).buildOrUpgrade('biblio'), isFalse);
    expect(st(c).levelOf('biblio'), 0);
  });

  test(
    'seção 6.7: objetivos do Maternal, resgate +2 ⭐ e medalha, só uma vez',
    () async {
      final c = await build();
      await ctrl(c).chooseGrade(0);
      expect(ctrl(c).missionDone(1), isFalse);
      expect(await ctrl(c).claim(1), isFalse);

      for (var i = 0; i < 6; i++) {
        await ctrl(c).completeLesson();
      }
      expect(ctrl(c).missionProgress(1), 6);
      expect(ctrl(c).claimableCount, 1);
      final before = st(c).stars;
      expect(await ctrl(c).claim(1), isTrue);
      expect(st(c).stars, before + 2);
      expect(st(c).medals, 1);
      expect(await ctrl(c).claim(1), isFalse); // não resgata de novo
      expect(ctrl(c).claimableCount, 0);
    },
  );

  test('seção 6.7: passar de ano reinicia aulas e objetivos do ano, mantém o construído e marca espaços novos', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    expect(await ctrl(c).promote(), PromotionResult.notReady);

    // Cumpre os 3 objetivos do Maternal: 3 espaços, 6 aulas, 1 melhoria.
    for (var i = 0; i < 9; i++) {
      await ctrl(c).completeLesson();
    }
    await ctrl(c).buildOrUpgrade('horta');
    await ctrl(c).buildOrUpgrade('atelie');
    await ctrl(c).buildOrUpgrade('sala');
    for (var i = 0; i < 3; i++) {
      expect(await ctrl(c).claim(i), isTrue, reason: 'objetivo $i');
    }

    expect(await ctrl(c).promote(), PromotionResult.promoted);
    expect(st(c).grade, 1);
    expect(st(c).lessonsYear, 0);
    expect(st(c).claimed, [false, false, false]);
    expect(st(c).levelOf('sala'), 2); // construído continua
    expect(st(c).fresh, ['biblio', 'patio']);
    expect(ctrl(c).suggestion(), 'biblio'); // espaço novo tem prioridade
    // Contagem de espaços é absoluta: já tem 3 dos 5 do Pré I.
    expect(ctrl(c).missionProgress(0), 3);
  });

  test('Pré II: com os objetivos resgatados vira formatura, e tudo continua jogável', () async {
    final c = await build();
    await ctrl(c).chooseGrade(2);
    for (var i = 0; i < 40; i++) {
      await ctrl(c).completeLesson();
    }
    for (final id in ['horta', 'atelie', 'biblio', 'patio', 'refeit']) {
      expect(await ctrl(c).buildOrUpgrade(id), isTrue, reason: id);
    }
    for (final id in ['sala', 'sala', 'horta', 'horta']) {
      expect(await ctrl(c).buildOrUpgrade(id), isTrue, reason: id);
    }
    for (var i = 0; i < 3; i++) {
      expect(await ctrl(c).claim(i), isTrue, reason: 'objetivo $i');
    }
    expect(await ctrl(c).promote(), PromotionResult.graduated);
    expect(st(c).graduated, isTrue);
    expect(st(c).grade, 2);
    expect(await ctrl(c).promote(), PromotionResult.notReady);
    await ctrl(c).completeLesson(); // continua jogável
  });

  test('Anexo B: trocar de série na área dos pais mantém o construído e reinicia objetivos e aulas do ano', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    for (var i = 0; i < 6; i++) {
      await ctrl(c).completeLesson();
    }
    await ctrl(c).buildOrUpgrade('horta');
    await ctrl(c).claim(1);

    await ctrl(c).chooseGrade(1);
    expect(st(c).levelOf('horta'), 1);
    expect(st(c).lessonsYear, 0);
    expect(st(c).claimed, [false, false, false]);
    expect(st(c).medals, 1); // medalhas já ganhas não se perdem
  });

  test('Anexo B: sugestão — construção possível, depois melhoria possível, senão a Sala', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    expect(ctrl(c).suggestion(), 'horta'); // 3 ⭐ dá pra construir
    await ctrl(c).buildOrUpgrade('horta');
    expect(ctrl(c).suggestion(), 'sala'); // 0 ⭐: cai na Sala
    for (var i = 0; i < 2; i++) {
      await ctrl(c).completeLesson();
    }
    expect(ctrl(c).suggestion(), 'atelie'); // construir vem antes de melhorar
    await ctrl(c).buildOrUpgrade('atelie');
    for (var i = 0; i < 2; i++) {
      await ctrl(c).completeLesson();
    }
    expect(ctrl(c).suggestion(), 'sala'); // 6 ⭐: melhoria da Sala
    expect(ctrl(c).canAfford('sala'), isTrue);
  });

  test('Anexo B: população de alunos = min(14, 2 + soma dos níveis)', () async {
    final c = await build(
      prefs: {
        'genius_kiddo_school_v1': jsonEncode({
          'grade': 2,
          'built': {
            'sala': 3,
            'horta': 3,
            'atelie': 3,
            'biblio': 3,
            'patio': 3,
            'refeit': 3,
          },
        }),
      },
    );
    expect(ctrl(c).totalLevels, 18);
    expect(ctrl(c).kids, 14);
  });

  test('seção 4.9: estado da escola persiste entre sessões', () async {
    final c = await build();
    await ctrl(c).chooseGrade(1);
    await ctrl(c).buildOrUpgrade('horta');
    final saved = c.read(persistenceServiceProvider).schoolStateJson!;

    final c2 = await build(prefs: {'genius_kiddo_school_v1': saved});
    expect(st(c2).grade, 1);
    expect(st(c2).levelOf('horta'), 1);
    expect(st(c2).stars, 0);
  });

  test('RF-FASE-01/03: Escolinha libera ao concluir a trilha ou pela liberação dos pais', () async {
    final c = await build(prefs: {'genius_kiddo_trail_done_v1': 7});
    expect(c.read(phase2UnlockedProvider), isFalse);
    await c.read(trailControllerProvider.notifier).complete(7);
    expect(c.read(phase2UnlockedProvider), isTrue);

    final c2 = await build();
    expect(c2.read(phase2UnlockedProvider), isFalse);
    await c2.read(phase2UnlockedProvider.notifier).unlockManually();
    expect(c2.read(phase2UnlockedProvider), isTrue);
    final c3 = await build(prefs: {'genius_kiddo_phase2_unlocked_v1': true});
    expect(c3.read(phase2UnlockedProvider), isTrue);
  });
}
