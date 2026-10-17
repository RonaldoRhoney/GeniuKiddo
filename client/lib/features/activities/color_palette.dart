import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/labels.dart';
import '../../l10n/generated/app_localizations.dart';

/// Paleta de cores da pintura e do rabisco livre: cada cor com o nome
/// escrito embaixo (nunca só pela cor, 4.10), alvo de toque de 64 dp, e
/// rótulo + estado "selecionada" pro leitor de tela. Quebra em duas linhas
/// em tela estreita em vez de encolher os alvos.
class ColorPaletteBar extends StatelessWidget {
  const ColorPaletteBar({
    super.key,
    required this.ids,
    required this.selectedId,
    required this.onPick,
    this.trailing,
  });

  final List<String> ids;
  final String selectedId;
  final void Function(int index) onPick;

  /// Botão extra no fim (ex.: "Limpar" do rabisco livre).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < ids.length; i++)
          Semantics(
            button: true,
            selected: ids[i] == selectedId,
            label: colorName(l10n, ids[i]),
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('color_${ids[i]}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(i),
              child: SizedBox(
                width: 64,
                height: 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: PaintPalette.byId(ids[i]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ids[i] == selectedId
                              ? colors.ink
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      colorName(l10n, ids[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ?trailing,
      ],
    );
  }
}
