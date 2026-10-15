// Modelos de conteúdo (seção 10): "orientado a dados" — adicionar um item
// ou uma etapa é editar `assets/content/*.json`, nunca mudar código de tela.

class ItemDef {
  const ItemDef({required this.id, required this.emoji, required this.articlePt});

  final String id;
  final String emoji;
  final String articlePt;

  factory ItemDef.fromJson(String id, Map<String, dynamic> json) =>
      ItemDef(id: id, emoji: json['emoji'] as String, articlePt: json['articlePt'] as String);
}

enum ActivityType { paint, listen, match, trace, speak }

class TrailNodeDef {
  const TrailNodeDef({required this.id, required this.type, this.art, this.items, this.glyph});

  final String id;
  final ActivityType type;
  final String? art; // paint
  final List<String>? items; // listen, match, speak
  final String? glyph; // trace

  factory TrailNodeDef.fromJson(Map<String, dynamic> json) => TrailNodeDef(
        id: json['id'] as String,
        type: ActivityType.values.byName(json['type'] as String),
        art: json['art'] as String?,
        items: (json['items'] as List?)?.cast<String>(),
        glyph: json['glyph'] as String?,
      );
}
