import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/persistence_service.dart';

enum TrailNodeStatus { done, current, locked }

class TrailState {
  const TrailState({required this.done, required this.stars});

  /// Quantas etapas já foram concluídas (0..N) — a próxima é a "atual".
  final int done;
  final int stars;

  TrailState copyWith({int? done, int? stars}) =>
      TrailState(done: done ?? this.done, stars: stars ?? this.stars);
}

/// Progressão da Fase 1 (seção 5.2 + 4.6): "libera por participação, não
/// por acerto" — toda etapa concebida aqui já é "a atividade terminou",
/// nunca um teste de acerto mínimo. "+1 estrela apenas na primeira
/// conclusão" (nunca de novo se a criança rejogar uma etapa já concluída).
class TrailController extends Notifier<TrailState> {
  @override
  TrailState build() {
    final p = ref.watch(persistenceServiceProvider);
    return TrailState(done: p.trailDone, stars: p.stars);
  }

  TrailNodeStatus statusOf(int index) {
    if (index < state.done) return TrailNodeStatus.done;
    if (index == state.done) return TrailNodeStatus.current;
    return TrailNodeStatus.locked;
  }

  /// Retorna `true` quando foi a primeira conclusão desta etapa (pra tela
  /// de celebração decidir se mostra "+1").
  Future<bool> complete(int index) async {
    final isFirst = index == state.done;
    if (!isFirst) return false;
    final p = ref.read(persistenceServiceProvider);
    final newDone = state.done + 1;
    final newStars = state.stars + 1;
    await p.setTrailDone(newDone);
    await p.setStars(newStars);
    state = state.copyWith(done: newDone, stars: newStars);
    return true;
  }
}

final trailControllerProvider = NotifierProvider<TrailController, TrailState>(
  TrailController.new,
);
