import 'package:flutter/material.dart';

import '../../app/guide_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';

/// Esqueleto comum de toda tela de atividade (seção 4.2): guia visível no
/// topo com balão de fala (texto sempre exibido, pros pais, além de falado
/// via `ItemFeedback`) e botão de repetir. Idioma e aparência sempre
/// alcançáveis daqui (seção 4.5/4.7), não só na área dos pais. Corpo livre
/// por atividade.
class ActivityShell extends StatelessWidget {
  const ActivityShell({
    super.key,
    required this.bubbleText,
    required this.body,
    this.onRepeat,
  });

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
                  KidIconButton(
                    icon: Icons.home_rounded,
                    label: AppLocalizations.of(context)!.homeButton,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  // Em telas estreitas os controles encolhem o mínimo
                  // necessário, como no menu, na trilha e na escola.
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: TopControls(),
                    ),
                  ),
                ],
              ),
            ),
            GuideBubbleRow(
              text: bubbleText,
              onRepeat: onRepeat,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
