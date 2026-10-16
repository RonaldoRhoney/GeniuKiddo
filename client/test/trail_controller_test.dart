import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/features/trail/trail_controller.dart';

void main() {
  late ProviderContainer container;

  Future<ProviderContainer> buildContainer({
    int trailDone = 0,
    int stars = 0,
  }) async {
    SharedPreferences.setMockInitialValues({
      'genius_kiddo_trail_done_v1': trailDone,
      'genius_kiddo_stars_v1': stars,
    });
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [
        persistenceServiceProvider.overrideWithValue(PersistenceService(prefs)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('status: 0..done-1 = done, done = current, resto = locked', () async {
    container = await buildContainer(trailDone: 2);
    final c = container.read(trailControllerProvider.notifier);
    expect(c.statusOf(0), TrailNodeStatus.done);
    expect(c.statusOf(1), TrailNodeStatus.done);
    expect(c.statusOf(2), TrailNodeStatus.current);
    expect(c.statusOf(3), TrailNodeStatus.locked);
  });

  test(
    'seção 5.2: +1 estrela só na primeira conclusão de cada etapa',
    () async {
      container = await buildContainer();
      final c = container.read(trailControllerProvider.notifier);

      final firstResult = await c.complete(0);
      expect(firstResult, isTrue);
      expect(container.read(trailControllerProvider).done, 1);
      expect(container.read(trailControllerProvider).stars, 1);

      // Replay da MESMA etapa (índice 0, já concluída) não soma estrela de
      // novo — "libera por participação" nunca vira fonte infinita de XP.
      final replayResult = await c.complete(0);
      expect(replayResult, isFalse);
      expect(container.read(trailControllerProvider).stars, 1);
    },
  );

  test('conclusão persiste entre sessões (seção 4.9)', () async {
    SharedPreferences.setMockInitialValues({});
    var prefs = await SharedPreferences.getInstance();
    var c = ProviderContainer(
      overrides: [
        persistenceServiceProvider.overrideWithValue(PersistenceService(prefs)),
      ],
    );
    await c.read(trailControllerProvider.notifier).complete(0);
    c.dispose();

    // "nova sessão": mesmo SharedPreferences, container novo.
    prefs = await SharedPreferences.getInstance();
    c = ProviderContainer(
      overrides: [
        persistenceServiceProvider.overrideWithValue(PersistenceService(prefs)),
      ],
    );
    addTearDown(c.dispose);
    expect(c.read(trailControllerProvider).done, 1);
    expect(c.read(trailControllerProvider).stars, 1);
  });
}
