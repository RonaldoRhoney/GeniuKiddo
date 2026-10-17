import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Portão dos pais (seção 4.7): "botão que exige segurar por 2 segundos —
/// a criança pequena não consegue". Reutilizado pelo botão "🔒 Pais" do
/// topo, pela pausa sugerida (seção 4.8) e pela escolha da série.
///
/// Sem `label`: só o cadeado com o anel de progresso. Com `label`: pílula
/// "🔒 Pais" que vai se enchendo enquanto o adulto segura; um toque rápido
/// mostra `hint` ("Segure para abrir") no lugar do texto.
class HoldToUnlock extends StatefulWidget {
  const HoldToUnlock({
    super.key,
    required this.onUnlock,
    this.icon = Icons.lock_outline_rounded,
    this.size = 40,
    this.semanticLabel,
    this.label,
    this.hint,
  });

  final VoidCallback onUnlock;
  final IconData icon;
  final double size;
  final String? semanticLabel;
  final String? label;
  final String? hint;

  @override
  State<HoldToUnlock> createState() => _HoldToUnlockState();
}

class _HoldToUnlockState extends State<HoldToUnlock>
    with SingleTickerProviderStateMixin {
  // `preserve`: os 2 s valem mesmo com "remover animações" ligado no
  // aparelho — sem isso o Android acelera a animação e um toque longo comum
  // abriria o portão.
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
        animationBehavior: AnimationBehavior.preserve,
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          widget.onUnlock();
        }
      });

  bool _showHint = false;
  Timer? _hintTimer;

  void _tap() {
    if (widget.hint == null) return;
    setState(() => _showHint = true);
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      onLongPressStart: (_) => _controller.forward(),
      onLongPressEnd: (_) => _controller.reverse(),
      onLongPressCancel: () => _controller.reverse(),
      child: Semantics(
        button: true,
        label: widget.semanticLabel,
        hint: widget.hint,
        excludeSemantics: true,
        child: widget.label == null ? _ring(colors) : _pill(colors),
      ),
    );
  }

  Widget _ring(AppColors colors) {
    return SizedBox(
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
    );
  }

  Widget _pill(AppColors colors) {
    // Largura fixa: mostrar a dica não pode empurrar os outros botões.
    return Container(
      height: 64,
      width: 108,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colors.purple.withValues(alpha: .5),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            // Enche da esquerda pra direita enquanto o adulto segura.
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _controller.value,
                child: ColoredBox(color: colors.purple.withValues(alpha: .35)),
              ),
            ),
            child!,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 22, color: colors.ink),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _showHint ? widget.hint! : widget.label!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: _showHint ? 12 : 17,
                    height: 1.1,
                    color: colors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
