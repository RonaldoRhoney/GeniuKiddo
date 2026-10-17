import 'package:flutter/material.dart';

import 'theme.dart';

/// Portão dos pais (seção 4.7): "botão que exige segurar por 2 segundos —
/// a criança pequena não consegue". Reutilizado tanto pelo cadeado que leva
/// à área dos pais quanto pela pausa sugerida (seção 4.8), que só sai pelo
/// mesmo gesto.
class HoldToUnlock extends StatefulWidget {
  const HoldToUnlock({
    super.key,
    required this.onUnlock,
    this.icon = Icons.lock_outline_rounded,
    this.size = 40,
    this.semanticLabel,
  });

  final VoidCallback onUnlock;
  final IconData icon;
  final double size;
  final String? semanticLabel;

  @override
  State<HoldToUnlock> createState() => _HoldToUnlockState();
}

class _HoldToUnlockState extends State<HoldToUnlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.reset();
            widget.onUnlock();
          }
        });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _controller.forward(),
      onLongPressEnd: (_) => _controller.reverse(),
      onLongPressCancel: () => _controller.reverse(),
      child: Semantics(
        button: true,
        label: widget.semanticLabel,
        excludeSemantics: true,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 3,
                  backgroundColor: colors.ink.withValues(alpha: .12),
                  valueColor: AlwaysStoppedAnimation(
                    colors.ink.withValues(alpha: .45),
                  ),
                ),
                Icon(
                  widget.icon,
                  size: widget.size * 0.5,
                  color: colors.ink.withValues(alpha: .45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
