// Modelos de conteúdo (seção 10): "orientado a dados" — adicionar um item
// ou uma etapa é editar `assets/content/*.json`, nunca mudar código de tela.

class ItemDef {
  const ItemDef({required this.id, required this.emoji, required this.gender});

  final String id;
  final String emoji;

  /// Gênero gramatical POR IDIOMA ("m"/"f"), porque muda de um idioma pro
  /// outro (maçã é feminino em pt, masculino em alemão). Idioma sem gênero
  /// (inglês) simplesmente não aparece aqui. Quem decide o artigo é a
  /// tradução (mensagens `select` no ARB), nunca o código.
  final Map<String, String> gender;

  /// "m", "f" ou "other" (idioma sem gênero ou não informado).
  String genderIn(String languageCode) => gender[languageCode] ?? 'other';

  factory ItemDef.fromJson(String id, Map<String, dynamic> json) => ItemDef(
    id: id,
    emoji: json['emoji'] as String,
    gender: (json['gender'] as Map<String, dynamic>? ?? const {})
        .cast<String, String>(),
  );
}

enum ActivityType { paint, listen, match, trace, speak }

class TrailNodeDef {
  const TrailNodeDef({
    required this.id,
    required this.type,
    this.art,
    this.items,
    this.glyph,
  });

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

// ---------------------------------------------------------------- Fase 2

/// Aula hospedada por um espaço da escola (seção 6.4).
enum LessonType { shapes, count, paint, letters, rhythm, sorting }

class GradeDef {
  const GradeDef({required this.icon, required this.age});

  final String icon;
  final int age;

  factory GradeDef.fromJson(Map<String, dynamic> json) =>
      GradeDef(icon: json['icon'] as String, age: json['age'] as int);
}

class SpaceDef {
  const SpaceDef({
    required this.id,
    required this.grade,
    required this.icon,
    required this.lesson,
    required this.levels,
    this.x = 0,
    this.y = 0,
  });

  final String id;

  /// Série a partir da qual o espaço fica disponível (0 = Maternal).
  final int grade;
  final String icon;
  final LessonType lesson;

  /// Visual de cada nível (1 → 3), em emojis até as artes finais (M8).
  final List<List<String>> levels;

  int get maxLevel => levels.length;

  /// Centro do terreno no mapa (M6, unidades do mundo — ver `WorldDef`).
  /// A ordem dos espaços no `school.json` é também a ordem do caminho.
  final double x;
  final double y;

  factory SpaceDef.fromJson(Map<String, dynamic> json) => SpaceDef(
    id: json['id'] as String,
    grade: json['grade'] as int,
    icon: json['icon'] as String,
    lesson: LessonType.values.byName(json['lesson'] as String),
    levels: [
      for (final l in json['levels'] as List) (l as List).cast<String>(),
    ],
    x: (json['x'] as num?)?.toDouble() ?? 0,
    y: (json['y'] as num?)?.toDouble() ?? 0,
  );
}

/// Mapa livre da escola (M6, seção 7): tamanho do mundo em unidades
/// próprias (1 unidade ≈ 1 dp com a escala fixa, RM-04) e lado do terreno.
class WorldDef {
  const WorldDef({
    required this.width,
    required this.height,
    required this.lotSize,
  });

  final double width;
  final double height;
  final double lotSize;

  factory WorldDef.fromJson(Map<String, dynamic> json) => WorldDef(
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    lotSize: (json['lotSize'] as num).toDouble(),
  );
}

/// Região de uma série no mapa — fica coberta por nuvens até a criança
/// chegar nessa série (RM-06).
class RegionDef {
  const RegionDef({
    required this.grade,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int grade;
  final double x;
  final double y;
  final double width;
  final double height;

  bool contains(double px, double py) =>
      px >= x && px <= x + width && py >= y && py <= y + height;

  factory RegionDef.fromJson(Map<String, dynamic> json) => RegionDef(
    grade: json['grade'] as int,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );
}

enum MissionType { build, lessons, level }

/// Objetivo do ano (seção 6.7). `level` só vale pra `MissionType.level`:
/// "ter `n` espaços com nível ≥ `level`".
class MissionDef {
  const MissionDef({
    required this.type,
    required this.n,
    required this.icon,
    this.level = 0,
  });

  final MissionType type;
  final int n;
  final String icon;
  final int level;

  factory MissionDef.fromJson(Map<String, dynamic> json) => MissionDef(
    type: MissionType.values.byName(json['type'] as String),
    n: json['n'] as int,
    icon: json['icon'] as String,
    level: json['level'] as int? ?? 0,
  );
}

class SchoolDef {
  const SchoolDef({
    required this.grades,
    required this.spaces,
    required this.startStars,
    required this.startBuilt,
    required this.buildCost,
    required this.upgradeCosts,
    required this.reward,
    required this.bonus,
    required this.maxKids,
    required this.missions,
    required this.world,
    required this.regions,
  });

  final WorldDef world;
  final List<RegionDef> regions;
  final List<GradeDef> grades;
  final List<SpaceDef> spaces;
  final int startStars;
  final Map<String, int> startBuilt;
  final int buildCost;

  /// Custo pra ir do nível 1 → 2, 2 → 3, ...
  final List<int> upgradeCosts;
  final int reward;
  final int bonus;
  final int maxKids;

  /// Objetivos por série (índice = série).
  final List<List<MissionDef>> missions;

  int get lastGrade => grades.length - 1;

  SpaceDef space(String id) => spaces.firstWhere(
    (s) => s.id == id,
    orElse: () => throw StateError('espaço desconhecido: $id'),
  );

  factory SchoolDef.fromJson(Map<String, dynamic> json) {
    final costs = json['costs'] as Map<String, dynamic>;
    return SchoolDef(
      grades: [
        for (final g in json['grades'] as List)
          GradeDef.fromJson(g as Map<String, dynamic>),
      ],
      spaces: [
        for (final s in json['spaces'] as List)
          SpaceDef.fromJson(s as Map<String, dynamic>),
      ],
      startStars: json['startStars'] as int,
      startBuilt: (json['startBuilt'] as Map<String, dynamic>)
          .cast<String, int>(),
      buildCost: costs['build'] as int,
      upgradeCosts: (costs['upgrade'] as List).cast<int>(),
      reward: json['reward'] as int,
      bonus: json['bonus'] as int,
      maxKids: json['maxKids'] as int,
      world: WorldDef.fromJson(json['world'] as Map<String, dynamic>),
      regions: [
        for (final r in json['regions'] as List)
          RegionDef.fromJson(r as Map<String, dynamic>),
      ],
      missions: [
        for (final g in json['missions'] as List)
          [
            for (final m in g as List)
              MissionDef.fromJson(m as Map<String, dynamic>),
          ],
      ],
    );
  }
}
