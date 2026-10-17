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
    'circle' => l10n.shapeCircle,
    'square' => l10n.shapeSquare,
    'triangle' => l10n.shapeTriangle,
    'star' => l10n.shapeStar,
    'heart' => l10n.shapeHeart,
    'flower' => l10n.itemFlower,
    'moon' => l10n.itemMoon,
    'house' => l10n.itemHouse,
    'grape' => l10n.itemGrape,
    'frog' => l10n.itemFrog,
    'duck' => l10n.itemDuck,
    'cow' => l10n.itemCow,
    'lion' => l10n.itemLion,
    'egg' => l10n.itemEgg,
    'bee' => l10n.itemBee,
    'bear' => l10n.itemBear,
    'strawberry' => l10n.itemStrawberry,
    'orange' => l10n.itemOrange,
    'watermelon' => l10n.itemWatermelon,
    'carrot' => l10n.itemCarrot,
    'broccoli' => l10n.itemBroccoli,
    'potato' => l10n.itemPotato,
    'lettuce' => l10n.itemLettuce,
    'onion' => l10n.itemOnion,
    _ => throw StateError('item sem tradução: $itemId'),
  };
}

/// Gênero do item no idioma ativo, pra as mensagens `select` do ARB
/// escolherem o artigo e a concordância ("no gato"/"na bola"). Um idioma
/// novo só precisa do próprio ARB e do gênero em `items.json`.
String itemGender(BuildContext context, ItemDef item) =>
    item.genderIn(Localizations.localeOf(context).languageCode);

/// Cor como adjetivo, concordando com o gênero do substantivo ("a estrela
/// vermelha"); cada idioma resolve a própria forma no ARB.
String colorAdjective(AppLocalizations l10n, String colorId, String gender) {
  return switch (colorId) {
    'red' => l10n.colorRedFor(gender),
    'blue' => l10n.colorBlueFor(gender),
    'yellow' => l10n.colorYellowFor(gender),
    'green' => l10n.colorGreenFor(gender),
    'purple' => l10n.colorPurpleFor(gender),
    _ => colorName(l10n, colorId),
  };
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
