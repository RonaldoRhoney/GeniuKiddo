import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../core/language_controller.dart';
import '../../core/supported_languages.dart';
import '../home/home_screen.dart';

/// Escolha de idioma (seção 4.5, só na 1ª vez — a Splash decide se cai aqui
/// ou direto no menu inicial). Um cartão grande por idioma de
/// `supportedLanguages`, com a bandeira e o nome do idioma —
/// adicionar um idioma novo na lista central já aparece aqui sozinho, sem
/// mudar esta tela.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _cardColors = AppColors.brandCycle;

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
                          key: ValueKey(
                            'langCard_${supportedLanguages[i].code}',
                          ),
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
  const _LanguageCard({super.key, required this.lang, required this.color});

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
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 8),
          child: Semantics(
            button: true,
            label: lang.nativeName,
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 56)),
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
      ),
    );
  }
}
