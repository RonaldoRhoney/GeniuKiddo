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
  Future<void> lessons(ProviderContainer c, int n) async {
    for (var i = 0; i < n; i++) {
      await ctrl(c).completeLesson();
    }
  }

  /// Constrói `id` respeitando a ordem: faz aulas até ter estrelas e até o
  /// anterior ter a sua aula (a aula da vez sempre vai pro espaço sem aula).
  Future<void> buildInOrder(ProviderContainer c, String id) async {
    for (var guard = 0; guard < 40; guard++) {
      if (await ctrl(c).buildOrUpgrade(id)) return;
      await ctrl(c).completeLesson();
    }
    fail('não conseguiu construir $id');
  }

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

  group('ordem de liberação', () {
    test('espaço só abre com o anterior construído + 1 aula', () async {
      final c = await build();
      await ctrl(c).chooseGrade(0);
      final def = c.read(contentRepositoryProvider).school;

      // Sala construída mas sem aula: Horta trancada, mesmo com 3 ⭐.
      expect(ctrl(c).blockedBy(def.space('horta'))?.id, 'sala');
      expect(await ctrl(c).buildOrUpgrade('horta'), isFalse);
      expect(st(c).stars, 3);

      await ctrl(c).completeLesson('sala');
      expect(ctrl(c).blockedBy(def.space('horta')), isNull);
      expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);

      // Horta construída mas sem aula: Ateliê trancado.
      expect(ctrl(c).blockedBy(def.space('atelie'))?.id, 'horta');
      await lessons(c, 1); // aula da vez = Horta (ainda sem aula)
      expect(st(c).lessonsIn('horta'), 1);
      expect(ctrl(c).blockedBy(def.space('atelie')), isNull);
    });

    test(
      'aula da vez: espaço sem aula primeiro, depois rodízio na ordem',
      () async {
        final c = await build();
        await ctrl(c).chooseGrade(0);
        expect(ctrl(c).currentLessonSpace(), 'sala');
        await lessons(c, 1);
        await ctrl(c).buildOrUpgrade('horta');
        expect(ctrl(c).currentLessonSpace(), 'horta'); // novo, sem aula
        await lessons(c, 1);
        expect(ctrl(c).currentLessonSpace(), 'sala'); // rodízio
        await lessons(c, 1);
        expect(ctrl(c).currentLessonSpace(), 'horta');
      },
    );

    test(
      'objetivos em ordem: o 2º só pode ser resgatado depois do 1º',
      () async {
        final c = await build();
        await ctrl(c).chooseGrade(0);
        await lessons(c, 6); // cumpre o objetivo 2 (6 aulas), não o 1
        expect(ctrl(c).missionDone(1), isTrue);
        expect(ctrl(c).missionUnlocked(1), isFalse);
        expect(ctrl(c).claimableCount, 0);
        expect(await ctrl(c).claim(1), isFalse);

        await buildInOrder(c, 'horta');
        await buildInOrder(c, 'atelie');
        expect(await ctrl(c).claim(0), isTrue); // 3 espaços
        expect(ctrl(c).missionUnlocked(1), isTrue);
        expect(await ctrl(c).claim(1), isTrue);
        expect(ctrl(c).missionUnlocked(2), isTrue);
      },
    );

    test(
      'progresso salvo fora de ordem é respeitado: construído nunca tranca',
      () async {
        final c = await build(
          prefs: {
            'genius_kiddo_school_v1': jsonEncode({
              'grade': 0,
              'built': {'sala': 1, 'atelie': 1},
            }),
          },
        );
        final def = c.read(contentRepositoryProvider).school;
        expect(ctrl(c).blockedBy(def.space('atelie')), isNull);
        expect(ctrl(c).isAvailable(def.space('atelie')), isTrue);
        expect(ctrl(c).blockedBy(def.space('horta'))?.id, 'sala');
      },
    );
  });

  test('seção 6.5: construir custa 3, nível 2 custa 6, nível 3 custa 10; sem estrela não gasta', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    await lessons(c, 1); // libera a Horta: 6 ⭐

    expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);
    expect(st(c).stars, 3);
    expect(st(c).levelOf('horta'), 1);

    expect(ctrl(c).costFor('horta'), 6);
    expect(await ctrl(c).buildOrUpgrade('horta'), isFalse); // 3 < 6
    await lessons(c, 1);
    expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);
    expect(ctrl(c).costFor('horta'), 10);
    await lessons(c, 4);
    expect(await ctrl(c).buildOrUpgrade('horta'), isTrue);
    expect(st(c).levelOf('horta'), 3);
    expect(ctrl(c).costFor('horta'), isNull); // no máximo
    expect(await ctrl(c).buildOrUpgrade('horta'), isFalse);
  });

  test('seção 6.3: espaço de série futura não pode ser construído', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    await buildInOrder(c, 'horta');
    await buildInOrder(c, 'atelie');
    await lessons(c, 3);
    expect(await ctrl(c).buildOrUpgrade('biblio'), isFalse);
    expect(st(c).levelOf('biblio'), 0);
  });

  test('seção 6.7: resgate +2 ⭐ e medalha, só uma vez', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    expect(await ctrl(c).claim(0), isFalse);
    await buildInOrder(c, 'horta');
    await buildInOrder(c, 'atelie');
    expect(ctrl(c).claimableCount, 1);
    final before = st(c).stars;
    expect(await ctrl(c).claim(0), isTrue);
    expect(st(c).stars, before + 2);
    expect(st(c).medals, 1);
    expect(await ctrl(c).claim(0), isFalse); // não resgata de novo
  });

  test('seção 6.7: passar de ano reinicia aulas e objetivos do ano, mantém o construído e marca espaços novos', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    expect(await ctrl(c).promote(), PromotionResult.notReady);

    // Objetivos do Maternal: 3 espaços, 6 aulas, 1 melhoria.
    await buildInOrder(c, 'horta');
    await buildInOrder(c, 'atelie');
    await lessons(c, 6);
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
    // Contagem de espaços é absoluta: já tem 3 dos 5 do Pré I.
    expect(ctrl(c).missionProgress(0), 3);
  });

  test('Pré II: com os objetivos resgatados vira formatura, e tudo continua jogável', () async {
    final c = await build();
    await ctrl(c).chooseGrade(2);
    for (final id in ['horta', 'atelie', 'biblio', 'patio', 'refeit']) {
      await buildInOrder(c, id);
    }
    await lessons(c, 30);
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

  test('Anexo B: trocar de série mantém o construído e reinicia objetivos e aulas do ano', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    await buildInOrder(c, 'horta');
    await buildInOrder(c, 'atelie');
    await ctrl(c).claim(0);

    await ctrl(c).chooseGrade(1);
    expect(st(c).levelOf('horta'), 1);
    expect(st(c).levelOf('atelie'), 1);
    expect(st(c).lessonsYear, 0);
    expect(st(c).claimed, [false, false, false]);
    expect(st(c).medals, 1); // medalhas já ganhas não se perdem
  });

  test('Anexo B: sugestão — construção possível, depois melhoria possível, senão a aula da vez', () async {
    final c = await build();
    await ctrl(c).chooseGrade(0);
    expect(ctrl(c).suggestion(), 'sala'); // Horta trancada: aula na Sala
    await lessons(c, 1);
    expect(ctrl(c).suggestion(), 'horta'); // 6 ⭐ e Horta liberada
    await ctrl(c).buildOrUpgrade('horta');
    expect(ctrl(c).suggestion(), 'horta'); // 3 ⭐: aula da vez = Horta
    await lessons(c, 1);
    expect(ctrl(c).suggestion(), 'atelie'); // construir vem antes de melhorar
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
    await buildInOrder(c, 'horta');
    final saved = c.read(persistenceServiceProvider).schoolStateJson!;

    final c2 = await build(prefs: {'genius_kiddo_school_v1': saved});
    expect(st(c2).grade, 1);
    expect(st(c2).levelOf('horta'), 1);
    expect(st(c2).lessonsIn('sala'), 1);
    expect(st(c2).lastLessonSpace, 'sala');
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
