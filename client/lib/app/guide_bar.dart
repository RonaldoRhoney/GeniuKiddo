import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'guide_avatar.dart';
import 'theme.dart';

/// Botão redondo da área da criança: sempre ≥ 64 dp (seção 4.10) e com
/// rótulo para leitor de tela.
class KidIconButton extends StatelessWidget {
  const KidIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: label,
      iconSize: 28,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.of(context).card,
        shape: const CircleBorder(),
        minimumSize: const Size(64, 64),
      ),
    );
  }
}

/// Linha do guia (seção 4.2), igual em todas as telas da criança: o Kiddo,
/// o balão com o que ele está dizendo (o mesmo texto falado) e o 🔊 para
/// ouvir de novo.
class GuideBubbleRow extends StatelessWidget {
  const GuideBubbleRow({
    super.key,
    required this.text,
    required this.onRepeat,
    this.avatarSize = 56,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 4),
  });

  final String text;
  final VoidCallback? onRepeat;
  final double avatarSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          GuideAvatar(size: avatarSize),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
          if (onRepeat != null) ...[
            const SizedBox(width: 8),
            KidIconButton(
              icon: Icons.volume_up_rounded,
              label: AppLocalizations.of(context)!.repeatButton,
              onPressed: onRepeat,
            ),
          ],
        ],
      ),
    );
  }
}
