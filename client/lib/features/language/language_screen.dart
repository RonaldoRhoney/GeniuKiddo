import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../core/language_controller.dart';
import '../../core/supported_languages.dart';
import '../trail/trail_screen.dart';

/// Escolha de idioma (seção 4.5, só na 1ª vez pela rota normal — Splash
/// decide se cai aqui ou direto na trilha). Um cartão grande por idioma de
/// `supportedLanguages`, SEM bandeiras (evita associar idioma a país) —
/// adicionar um idioma novo na lista central já aparece aqui sozinho, sem
/// mudar esta tela.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  // Ciclo de cores de marca pros cartões — se um dia houver mais idiomas
  // que cores aqui, repete do início (nunca quebra, só repete tom).
  static const _cardColors = [
    Color(0xFF7C5CFF),
    Color(0xFF2F86E6),
    Color(0xFFFF9B3D),
    Color(0xFF4FCB8D),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GuideAvatar(size: MediaQuery.sizeOf(context).width * 0.38),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    for (var i = 0; i < supportedLanguages.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: _LanguageCard(
                          lang: supportedLanguages[i],
                          color: _cardColors[i % _cardColors.length],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends ConsumerWidget {
  const _LanguageCard({required this.lang, required this.color});

  final SupportedLanguage lang;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () async {
          await ref.read(languageControllerProvider.notifier).choose(lang.code);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const TrailScreen()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang.greeting,
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lang.nativeName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
