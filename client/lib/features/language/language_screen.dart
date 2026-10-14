import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../core/language_controller.dart';
import '../trail/trail_screen.dart';

/// Escolha de idioma (seção 4.5, só na 1ª vez pela rota normal — Splash
/// decide se cai aqui ou direto na trilha). Dois cartões grandes, SEM
/// bandeiras (evita associar idioma a país), mesmo padrão dos protótipos.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.light;
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
                    Expanded(child: _LanguageCard(code: 'pt', color: colors.purple, hi: 'Oi!', ref: ref)),
                    const SizedBox(width: 16),
                    Expanded(child: _LanguageCard(code: 'en', color: const Color(0xFF2F86E6), hi: 'Hi!', ref: ref)),
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.code, required this.color, required this.hi, required this.ref});

  final String code;
  final Color color;
  final String hi;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final label = code == 'pt' ? 'Português' : 'English';
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () async {
          await ref.read(languageControllerProvider.notifier).choose(code);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TrailScreen()));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hi, style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
