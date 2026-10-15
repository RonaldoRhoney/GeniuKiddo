import 'package:flutter/material.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';

/// Esqueleto comum de toda tela de atividade (seção 4.2): guia visível no
/// topo com balão de fala (texto sempre exibido, pros pais, além de falado
/// via `ItemFeedback`) e botão de repetir. Idioma e aparência sempre
/// alcançáveis daqui (seção 4.5/4.7), não só na área dos pais. Corpo livre
/// por atividade.
class ActivityShell extends StatelessWidget {
  const ActivityShell({super.key, required this.bubbleText, required this.body, this.onRepeat});

  final String bubbleText;
  final Widget body;
  final VoidCallback? onRepeat;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    style: IconButton.styleFrom(backgroundColor: colors.card, shape: const CircleBorder()),
                  ),
                  const Spacer(),
                  const TopControls(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  const GuideAvatar(size: 56),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(20)),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(bubbleText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                      ),
                    ),
                  ),
                  if (onRepeat != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onRepeat,
                      icon: const Icon(Icons.volume_up_rounded),
                      style: IconButton.styleFrom(backgroundColor: colors.card, shape: const CircleBorder()),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: body)),
          ],
        ),
      ),
    );
  }
}
