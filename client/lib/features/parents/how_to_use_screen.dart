import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Como usar" (pedido do Rhoney, 17/10/2026): guia curto para o adulto,
/// dentro do Controle dos pais. Cada tópico abre e fecha, pra a tela não
/// virar um paredão de texto. Os textos ficam nos ARB (seção 10).
class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final topics = [
      ('🏠', l10n.helpMenuTitle, l10n.helpMenuBody),
      ('🗺️', l10n.helpTrailTitle, l10n.helpTrailBody),
      ('🏫', l10n.helpSchoolTitle, l10n.helpSchoolBody),
      ('👆', l10n.helpMapTitle, l10n.helpMapBody),
      ('🧞', l10n.helpGuideTitle, l10n.helpGuideBody),
      ('🔒', l10n.helpParentsTitle, l10n.helpParentsBody),
      ('😴', l10n.helpBreakTitle, l10n.helpBreakBody),
      ('💡', l10n.helpStuckTitle, l10n.helpStuckBody),
    ];
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        title: Text(
          l10n.parentsCardHelp,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(l10n.helpIntro, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 14),
          for (final (icon, title, body) in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  // Sem as linhas divisórias padrão do ExpansionTile.
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: ValueKey('help_$title'),
                    leading: Text(icon, style: const TextStyle(fontSize: 26)),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(body, style: const TextStyle(height: 1.4))],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
