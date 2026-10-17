import 'package:flutter/material.dart';

import 'theme.dart';

/// Contador de estrelas da trilha e da escola. Fica no topo do conteúdo
/// (lista da trilha, mapa da escola), fora da barra de botões, pra a barra
/// ser igual em todas as telas e nenhum botão encolher.
class StarsPill extends StatelessWidget {
  const StarsPill({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      label: '⭐ $stars',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              '$stars',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
