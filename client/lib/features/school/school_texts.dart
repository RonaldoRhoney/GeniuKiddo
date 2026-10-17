import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';

/// Textos da escola que dependem de um id vindo do `school.json` — o ARB
/// não indexa por variável, então o mapeamento fica centralizado aqui.
extension SchoolTexts on AppLocalizations {
  String gradeName(int grade) => switch (grade) {
    0 => gradeName0,
    1 => gradeName1,
    _ => gradeName2,
  };

  String spaceName(String id) => switch (id) {
    'sala' => spaceName_sala,
    'horta' => spaceName_horta,
    'atelie' => spaceName_atelie,
    'biblio' => spaceName_biblio,
    'patio' => spaceName_patio,
    'refeit' => spaceName_refeit,
    _ => throw StateError('espaço sem texto: $id'),
  };

  String spaceDesc(String id) => switch (id) {
    'sala' => spaceDesc_sala,
    'horta' => spaceDesc_horta,
    'atelie' => spaceDesc_atelie,
    'biblio' => spaceDesc_biblio,
    'patio' => spaceDesc_patio,
    'refeit' => spaceDesc_refeit,
    _ => throw StateError('espaço sem texto: $id'),
  };

  String mission(MissionDef m) => switch (m.type) {
    MissionType.build => missionBuild(m.n),
    MissionType.lessons => missionLessons(m.n),
    MissionType.level => m.level >= 3 ? missionMax(m.n) : missionUpgrade(m.n),
  };
}
