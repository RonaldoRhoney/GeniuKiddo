import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../celebration/celebration_overlay.dart';
import 'activity_outcome.dart';

/// Peças comuns às aulas da escola (seção 6.8): cartão tocável com a dica
/// visual em amarelo e o fechamento padrão (registrar → celebrar → voltar).

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Registra a conclusão (+3 ⭐ na escola), mostra a celebração e volta.
Future<void> finishLesson(
  BuildContext context,
  WidgetRef ref,
  ActivityOutcome outcome,
  String message,
) async {
  final badge = await outcome.complete(ref);
  if (!context.mounted) return;
  await showCelebration(context, badge: badge, message: message);
  if (!context.mounted) return;
  Navigator.of(context).pop();
}

/// Cartão grande de opção (≥ 64 dp). `highlighted` = dica no alvo certo
/// depois de um toque fora do pedido (seção 4.6); `correct` = brilho verde.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.child,
    required this.onTap,
    required this.semanticLabel,
    this.highlighted = false,
    this.correct = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;
  final bool highlighted;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: correct
                  ? Border.all(color: colors.green, width: 7)
                  : highlighted
                  ? Border.all(color: colors.yellow, width: 7)
                  : null,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Esperas de uma atividade (pausa depois do acerto, antes da próxima
/// rodada). Todas são canceladas juntas ao reiniciar a atividade (troca de
/// idioma, seção 4.5) e ao fechar a tela — uma espera antiga nunca avança
/// a rodada da atividade já reiniciada.
mixin ActivityTimers<T extends StatefulWidget> on State<T> {
  final List<Timer> _timers = [];

  void later(Duration delay, VoidCallback action) {
    _timers.add(
      Timer(delay, () {
        if (mounted) action();
      }),
    );
  }

  void cancelLater() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    cancelLater();
    super.dispose();
  }
}
