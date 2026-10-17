import 'dart:math';

import 'package:flutter/widgets.dart';

/// "Balanço leve" (seções 5.2 e 6.6, RT-09): o filho treme para os lados
/// quando `trigger` muda — usado em item trancado, junto com o som sutil e
/// a fala do guia. Com "reduzir movimento" ligado, não treme.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});

  /// Qualquer mudança dispara um balanço (ex.: um contador de toques).
  final int trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(covariant Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger &&
        !MediaQuery.of(context).disableAnimations) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Três idas e vindas que vão perdendo força.
        final dx = sin(t * 6 * pi) * 10 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
