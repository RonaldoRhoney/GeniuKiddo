import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Indicador de progresso "N de T rodadas" (compartilhado por Ouvir,
/// Associar, Falar) — equivalente ao `.dots` dos protótipos.
class RoundDots extends StatelessWidget {
  const RoundDots({super.key, required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < current
                    ? colors.yellow
                    : i == current
                        ? colors.purple
                        : colors.ink.withValues(alpha: .14),
              ),
            ),
          ),
      ],
    );
  }
}
