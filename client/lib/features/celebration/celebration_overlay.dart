import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/item_feedback.dart';
import '../../l10n/generated/app_localizations.dart';

/// Celebração (seção 5.4): estrela grande, "+1" só na 1ª conclusão, confete
/// leve, som de vitória, fala de elogio (feita pelo chamador via
/// `ItemFeedback`, não aqui) e botão ▶ grande. Sempre modal — some só
/// quando a criança toca ▶. `icon`/`isFirstCompletion` suportam a variante
/// RT-08 (atividades livres): ícone próprio da atividade (ex. 🎨), sem
/// estrela nem "+1".
Future<void> showCelebration(
  BuildContext context, {
  required bool isFirstCompletion,
  required String message,
  String icon = '⭐',
}) {
  ProviderScope.containerOf(context, listen: false).read(itemFeedbackProvider).sound.play(FeedbackSound.win);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x991D1A3A),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => _CelebrationContent(isFirstCompletion: isFirstCompletion, message: message, icon: icon),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );
}

class _CelebrationContent extends StatelessWidget {
  const _CelebrationContent({required this.isFirstCompletion, required this.message, required this.icon});

  final bool isFirstCompletion;
  final String message;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _ConfettiLayer())),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(36)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 72)),
                  if (isFirstCompletion) ...[
                    const SizedBox(height: 6),
                    Text('+1', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.purple)),
                  ],
                  const SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19)),
                  const SizedBox(height: 22),
                  Material(
                    color: colors.green,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Icon(Icons.play_arrow_rounded, size: 42, color: Colors.white, semanticLabel: l10n.celebrationContinue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer();

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  late final List<_Particle> _particles = List.generate(18, (i) => _Particle(Random(i * 97)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        return Stack(
          children: [
            for (final p in _particles)
              Positioned(
                left: p.x * size.width,
                top: -40 + _controller.value * (size.height + 80) * p.speed,
                child: Opacity(
                  opacity: (1 - _controller.value).clamp(0.0, 1.0),
                  child: Transform.rotate(angle: _controller.value * p.spin, child: Text(p.emoji, style: const TextStyle(fontSize: 26))),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Particle {
  _Particle(Random r)
      : x = r.nextDouble(),
        speed = 0.6 + r.nextDouble() * 0.6,
        spin = (r.nextBool() ? 1 : -1) * (4 + r.nextDouble() * 4),
        emoji = const ['🎉', '⭐', '✨', '🎈', '💜'][r.nextInt(5)];

  final double x;
  final double speed;
  final double spin;
  final String emoji;
}
