import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../trail/trail_controller.dart';

/// Quem abre a atividade decide o que a conclusão vale — a mesma tela de
/// pintar serve à trilha (Fase 1, +1 ⭐ na 1ª vez) e ao Ateliê da escola
/// (Fase 2, +3 ⭐ sempre), sem a atividade conhecer nenhuma das duas.
abstract class ActivityOutcome {
  const ActivityOutcome();

  /// Registra a conclusão e devolve o selo da celebração ("+1", "+3"), ou
  /// `null` quando a conclusão não rende estrela.
  Future<String?> complete(WidgetRef ref);
}

/// Etapa da trilha (seção 5.2): +1 ⭐ só na primeira conclusão.
class TrailStepOutcome extends ActivityOutcome {
  const TrailStepOutcome(this.index);

  final int index;

  @override
  Future<String?> complete(WidgetRef ref) async {
    final isFirst = await ref
        .read(trailControllerProvider.notifier)
        .complete(index);
    return isFirst ? '+1' : null;
  }
}
