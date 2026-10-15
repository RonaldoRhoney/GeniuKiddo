import 'package:flutter/widgets.dart';

import '../content/models.dart';
import '../l10n/generated/app_localizations.dart';

/// Nome do item no idioma ativo (nunca gravado como texto fixo em
/// `ItemDef`/`assets/content/items.json` — só o id estável fica lá, seção
/// 10 "chaves de texto iguais nos dois idiomas").
String itemName(AppLocalizations l10n, String itemId) {
  return switch (itemId) {
    'dog' => l10n.itemDog,
    'cat' => l10n.itemCat,
    'fish' => l10n.itemFish,
    'bird' => l10n.itemBird,
    'apple' => l10n.itemApple,
    'banana' => l10n.itemBanana,
    'car' => l10n.itemCar,
    'ball' => l10n.itemBall,
    'sun' => l10n.itemSun,
    _ => throw StateError('item sem tradução: $itemId'),
  };
}

/// Artigo do item no idioma ativo. Em português usa o gênero de
/// `ItemDef.articlePt` (precisa pra concordância — "o gato"/"a bola"); em
/// inglês é sempre "the" (prototype: `en: ['the', name]`).
String itemArticle(BuildContext context, ItemDef item) {
  final isEnglish = Localizations.localeOf(context).languageCode == 'en';
  return isEnglish ? 'the' : item.articlePt;
}

String colorName(AppLocalizations l10n, String colorId) {
  return switch (colorId) {
    'red' => l10n.colorRed,
    'blue' => l10n.colorBlue,
    'yellow' => l10n.colorYellow,
    'green' => l10n.colorGreen,
    'purple' => l10n.colorPurple,
    'orange' => l10n.colorOrange,
    _ => throw StateError('cor sem tradução: $colorId'),
  };
}

String trailNodeTitle(AppLocalizations l10n, String nodeId) {
  return switch (nodeId) {
    'paint_garden' => l10n.trailNodePaintGarden,
    'listen_animals' => l10n.trailNodeListenAnimals,
    'match_shadow' => l10n.trailNodeMatchShadow,
    'trace_1' => l10n.trailNodeTrace1,
    'speak_words' => l10n.trailNodeSpeakWords,
    'paint_house' => l10n.trailNodePaintHouse,
    'listen_fruits' => l10n.trailNodeListenFruits,
    'trace_o' => l10n.trailNodeTraceO,
    _ => throw StateError('etapa sem título: $nodeId'),
  };
}

String glyphName(AppLocalizations l10n, String glyph) {
  return switch (glyph) {
    '1' => l10n.glyphName1,
    'O' => l10n.glyphNameO,
    _ => throw StateError('glifo sem nome: $glyph'),
  };
}

String randomPraise(AppLocalizations l10n, int seed) {
  final options = [l10n.praise1, l10n.praise2, l10n.praise3, l10n.praise4];
  return options[seed % options.length];
}
