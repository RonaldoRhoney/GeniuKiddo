import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/hold_to_unlock.dart';
import '../../app/theme.dart';
import '../../core/break_controller.dart';
import '../../core/item_feedback.dart';
import '../../l10n/generated/app_localizations.dart';

/// Pausa sugerida (seção 4.8): sobreposição modal com 😴 + fala, sem
/// contagem regressiva nem pressão (R14) — só sai pelo mesmo portão de
/// segurar 2s usado na área dos pais, nunca por um toque qualquer da
/// criança.
class BreakOverlay extends ConsumerStatefulWidget {
  const BreakOverlay({super.key});

  @override
  ConsumerState<BreakOverlay> createState() => _BreakOverlayState();
}

class _BreakOverlayState extends ConsumerState<BreakOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(itemFeedbackProvider)
          .speech
          .speak(AppLocalizations.of(context)!.breakMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    // O voltar do Android é segurado em `GeniusKiddoApp.didPopRoute`.
    return Material(
      color: const Color(0xE61D1A3A),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😴', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 10),
              Text(
                l10n.breakMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 26),
              HoldToUnlock(
                size: 56,
                semanticLabel: l10n.parentGateLabel,
                onUnlock: () =>
                    ref.read(breakControllerProvider.notifier).dismiss(),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.breakHoldHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.ink.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
