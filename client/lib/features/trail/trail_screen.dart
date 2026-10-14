import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../core/language_controller.dart';
import '../../l10n/generated/app_localizations.dart';

/// Placeholder — a Trilha de 8 etapas (seção 5) é entregue no M2. Por
/// enquanto só confirma que a navegação Splash → Idioma → cá funciona e
/// mostra a fala de boas-vindas certa (1ª vez vs. retorno, Anexo C).
class TrailScreen extends ConsumerWidget {
  const TrailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isFirstChoice = ref.watch(languageControllerProvider).isFirstChoice;
    final colors = AppColors.light;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GuideAvatar(size: 64),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        isFirstChoice ? l10n.welcomeFirst : l10n.welcomeBack,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(child: Center(child: Text(l10n.homePlaceholder, textAlign: TextAlign.center))),
            ],
          ),
        ),
      ),
    );
  }
}
