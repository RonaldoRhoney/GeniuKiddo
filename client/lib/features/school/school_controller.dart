import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../core/persistence_service.dart';
import '../trail/trail_controller.dart';

/// Estado da Escolinha (Fase 2, seção 6). Só configuração local, sem
/// nenhum dado pessoal (seção 4.9): a série é escolhida pelos pais, nunca
/// derivada de data de nascimento.
class SchoolState {
  const SchoolState({
    required this.grade,
    required this.stars,
    required this.built,
    required this.lessonsYear,
    required this.claimed,
    required this.medals,
    required this.graduated,
    required this.fresh,
    this.lessonsBySpace = const {},
    this.lastLessonSpace,
  });

  /// `null` = série ainda não escolhida (primeira entrada na escola).
  final int? grade;

  /// Estrelas da escola — contador próprio, separado das estrelas da
  /// trilha (decisão do plano do M5).
  final int stars;

  /// Nível de cada espaço construído (ausente = vazio).
  final Map<String, int> built;

  /// Aulas feitas no ano atual (reinicia ao passar de série, seção 6.7).
  final int lessonsYear;

  /// Objetivos do ano já resgatados (mesmo índice de `missions[grade]`).
  final List<bool> claimed;
  final int medals;

  /// Formatura feita no Pré II — tudo continua jogável depois.
  final bool graduated;

  /// Espaços que chegaram com a série nova e ainda não foram abertos
  /// (brilham como "novos" e têm prioridade na sugestão).
  final List<String> fresh;

  /// Aulas já feitas em cada espaço (total, não por ano) — regra de
  /// liberação em ordem: o próximo espaço só abre depois do anterior ter
  /// pelo menos 1 aula.
  final Map<String, int> lessonsBySpace;

  /// Espaço da última aula feita (rodízio das aulas em ordem).
  final String? lastLessonSpace;

  int lessonsIn(String spaceId) => lessonsBySpace[spaceId] ?? 0;

  factory SchoolState.initial(SchoolDef def) => SchoolState(
    grade: null,
    stars: def.startStars,
    built: Map.of(def.startBuilt),
    lessonsYear: 0,
    claimed: const [false, false, false],
    medals: 0,
    graduated: false,
    fresh: const [],
  );

  int levelOf(String spaceId) => built[spaceId] ?? 0;

  SchoolState copyWith({
    int? grade,
    int? stars,
    Map<String, int>? built,
    int? lessonsYear,
    List<bool>? claimed,
    int? medals,
    bool? graduated,
    List<String>? fresh,
    Map<String, int>? lessonsBySpace,
    String? lastLessonSpace,
  }) => SchoolState(
    grade: grade ?? this.grade,
    stars: stars ?? this.stars,
    built: built ?? this.built,
    lessonsYear: lessonsYear ?? this.lessonsYear,
    claimed: claimed ?? this.claimed,
    medals: medals ?? this.medals,
    graduated: graduated ?? this.graduated,
    fresh: fresh ?? this.fresh,
    lessonsBySpace: lessonsBySpace ?? this.lessonsBySpace,
    lastLessonSpace: lastLessonSpace ?? this.lastLessonSpace,
  );

  Map<String, dynamic> toJson() => {
    'grade': grade,
    'stars': stars,
    'built': built,
    'lessonsYear': lessonsYear,
    'claimed': claimed,
    'medals': medals,
    'graduated': graduated,
    'fresh': fresh,
    'lessonsBySpace': lessonsBySpace,
    'lastLessonSpace': lastLessonSpace,
  };

  /// Campo ausente cai no valor inicial — nunca quebra ao ler um estado
  /// salvo por uma versão mais antiga do app.
  factory SchoolState.fromJson(Map<String, dynamic> json, SchoolDef def) {
    final initial = SchoolState.initial(def);
    return SchoolState(
      grade: json['grade'] as int?,
      stars: json['stars'] as int? ?? initial.stars,
      built:
          (json['built'] as Map<String, dynamic>?)?.cast<String, int>() ??
          initial.built,
      lessonsYear: json['lessonsYear'] as int? ?? 0,
      claimed: (json['claimed'] as List?)?.cast<bool>() ?? initial.claimed,
      medals: json['medals'] as int? ?? 0,
      graduated: json['graduated'] as bool? ?? false,
      fresh: (json['fresh'] as List?)?.cast<String>() ?? const [],
      lessonsBySpace:
          (json['lessonsBySpace'] as Map<String, dynamic>?)
              ?.cast<String, int>() ??
          const {},
      lastLessonSpace: json['lastLessonSpace'] as String?,
    );
  }
}

/// Resultado de `promote()` pra a UI escolher a cerimônia certa.
enum PromotionResult { notReady, promoted, graduated }

/// Regras da Fase 2 (seção 6.5–6.7, Anexo B). Estrelas só vêm de aulas e
/// objetivos, nunca de tempo real; sem decaimento nem perda (R14).
class SchoolController extends Notifier<SchoolState> {
  SchoolDef get _def => ref.read(contentRepositoryProvider).school;

  @override
  SchoolState build() {
    final def = ref.watch(contentRepositoryProvider).school;
    final raw = ref.watch(persistenceServiceProvider).schoolStateJson;
    if (raw == null) return SchoolState.initial(def);
    return SchoolState.fromJson(jsonDecode(raw) as Map<String, dynamic>, def);
  }

  Future<void> _save(SchoolState next) async {
    state = next;
    await ref
        .read(persistenceServiceProvider)
        .setSchoolStateJson(jsonEncode(next.toJson()));
  }

  // ------------------------------------------------------------ consultas

  bool isOpen(SpaceDef space) => (state.grade ?? 0) >= space.grade;

  /// Regra "só desbloqueia quando o anterior for concluído": na ordem do
  /// `school.json`, um espaço só abre depois do anterior estar construído
  /// e ter pelo menos 1 aula. Retorna o espaço que está segurando este, ou
  /// `null` se nada segura. Espaço já construído nunca volta a trancar
  /// (progresso salvo é respeitado).
  SpaceDef? blockedBy(SpaceDef space) {
    if (state.levelOf(space.id) > 0) return null;
    final i = _def.spaces.indexWhere((s) => s.id == space.id);
    if (i <= 0) return null;
    final prev = _def.spaces[i - 1];
    final done = state.levelOf(prev.id) > 0 && state.lessonsIn(prev.id) > 0;
    return done ? null : prev;
  }

  /// Aberto pra série E liberado pela ordem.
  bool isAvailable(SpaceDef space) => isOpen(space) && blockedBy(space) == null;

  /// Aulas em ordem: só uma aula fica liberada por vez. Primeiro um espaço
  /// construído que ainda não teve aula (na ordem); se todos já tiveram,
  /// rodízio na ordem dos espaços a partir da última aula feita.
  String? currentLessonSpace() {
    final built = [
      for (final s in _def.spaces)
        if (isOpen(s) && state.levelOf(s.id) > 0) s.id,
    ];
    if (built.isEmpty) return null;
    for (final id in built) {
      if (state.lessonsIn(id) == 0) return id;
    }
    final last = built.indexOf(state.lastLessonSpace ?? '');
    return built[(last + 1) % built.length];
  }

  /// Custo do próximo passo (construir ou melhorar); `null` = no máximo.
  int? costFor(String spaceId) {
    final level = state.levelOf(spaceId);
    if (level == 0) return _def.buildCost;
    if (level - 1 >= _def.upgradeCosts.length) return null;
    return _def.upgradeCosts[level - 1];
  }

  bool canAfford(String spaceId) {
    final cost = costFor(spaceId);
    return cost != null && state.stars >= cost;
  }

  int get builtCount =>
      _def.spaces.where((s) => state.levelOf(s.id) > 0).length;

  int countAtLevel(int level) =>
      _def.spaces.where((s) => state.levelOf(s.id) >= level).length;

  int get totalLevels =>
      _def.spaces.fold(0, (sum, s) => sum + state.levelOf(s.id));

  /// Anexo B: `min(14, 2 + soma dos níveis)`.
  int get kids => (2 + totalLevels).clamp(0, _def.maxKids);

  List<MissionDef> get missions => _def.missions[state.grade ?? 0];

  int missionProgress(int index) {
    final m = missions[index];
    return switch (m.type) {
      MissionType.build => builtCount,
      MissionType.lessons => state.lessonsYear,
      MissionType.level => countAtLevel(m.level),
    };
  }

  bool missionDone(int index) => missionProgress(index) >= missions[index].n;

  /// Objetivos em ordem: o próximo só fica disponível depois do anterior
  /// ser resgatado.
  bool missionUnlocked(int index) => index == 0 || state.claimed[index - 1];

  int get claimableCount => [
    for (var i = 0; i < missions.length; i++)
      if (missionUnlocked(i) && missionDone(i) && !state.claimed[i]) i,
  ].length;

  bool get allClaimed => state.claimed.every((c) => c);

  /// Seção 6.6 / Anexo B, com a ordem de liberação: espaço novo da série
  /// (se já liberado), depois construção possível, depois melhoria
  /// possível, senão o espaço da aula da vez.
  String? suggestion() {
    if (state.grade == null) return null;
    final available = _def.spaces.where(isAvailable).toList();
    for (final id in state.fresh) {
      if (available.any((s) => s.id == id)) return id;
    }
    for (final s in available) {
      if (state.levelOf(s.id) == 0 && canAfford(s.id)) return s.id;
    }
    for (final s in available) {
      if (state.levelOf(s.id) > 0 && canAfford(s.id)) return s.id;
    }
    return currentLessonSpace() ?? _def.spaces.first.id;
  }

  // -------------------------------------------------------------- ações

  /// Primeira escolha ou troca na área dos pais. Nunca apaga o que foi
  /// construído (seção 6.3); a troca reinicia objetivos e aulas do ano
  /// (Anexo B).
  Future<void> chooseGrade(int grade) async {
    if (grade == state.grade) return;
    await _save(
      state.copyWith(
        grade: grade,
        lessonsYear: 0,
        claimed: const [false, false, false],
        fresh: const [],
      ),
    );
  }

  /// Retorna `false` se o espaço está fechado pra série, no máximo, ou
  /// faltam estrelas — a UI mostra o botão apagado nesses casos.
  Future<bool> buildOrUpgrade(String spaceId) async {
    final space = _def.space(spaceId);
    final cost = costFor(spaceId);
    if (!isAvailable(space) || cost == null || state.stars < cost) {
      return false;
    }
    await _save(
      state.copyWith(
        stars: state.stars - cost,
        built: {...state.built, spaceId: state.levelOf(spaceId) + 1},
        fresh: state.fresh.where((id) => id != spaceId).toList(),
      ),
    );
    return true;
  }

  /// Abrir um espaço "novo" tira o brilho dele.
  Future<void> markSeen(String spaceId) async {
    if (!state.fresh.contains(spaceId)) return;
    await _save(
      state.copyWith(fresh: state.fresh.where((id) => id != spaceId).toList()),
    );
  }

  /// Aula concluída: +3 ⭐ sempre (libera por participação, seção 4.6).
  /// `spaceId` = onde foi a aula (padrão: a aula da vez).
  Future<void> completeLesson([String? spaceId]) {
    final id = spaceId ?? currentLessonSpace() ?? _def.spaces.first.id;
    return _save(
      state.copyWith(
        stars: state.stars + _def.reward,
        lessonsYear: state.lessonsYear + 1,
        lessonsBySpace: {...state.lessonsBySpace, id: state.lessonsIn(id) + 1},
        lastLessonSpace: id,
      ),
    );
  }

  /// Objetivo cumprido e ainda não resgatado: +2 ⭐ e uma medalha.
  Future<bool> claim(int index) async {
    if (state.claimed[index] ||
        !missionUnlocked(index) ||
        !missionDone(index)) {
      return false;
    }
    final claimed = [...state.claimed]..[index] = true;
    await _save(
      state.copyWith(
        claimed: claimed,
        stars: state.stars + _def.bonus,
        medals: state.medals + 1,
      ),
    );
    return true;
  }

  /// Com os 3 objetivos resgatados: passa de ano (objetivos e aulas do ano
  /// reiniciam, espaços novos brilham) ou, no Pré II, formatura.
  Future<PromotionResult> promote() async {
    final grade = state.grade;
    if (grade == null || !allClaimed || state.graduated) {
      return PromotionResult.notReady;
    }
    if (grade >= _def.lastGrade) {
      await _save(state.copyWith(graduated: true));
      return PromotionResult.graduated;
    }
    final next = grade + 1;
    await _save(
      state.copyWith(
        grade: next,
        lessonsYear: 0,
        claimed: const [false, false, false],
        fresh: [
          for (final s in _def.spaces)
            if (s.grade == next) s.id,
        ],
      ),
    );
    return PromotionResult.promoted;
  }
}

final schoolControllerProvider =
    NotifierProvider<SchoolController, SchoolState>(SchoolController.new);

/// RF-FASE-01/02/03: a Escolinha libera ao concluir as 8 etapas da trilha,
/// ou antes, se os pais liberarem manualmente na área dos pais.
class Phase2UnlockController extends Notifier<bool> {
  @override
  bool build() {
    final trailDone = ref.watch(trailControllerProvider).done;
    final trailLength = ref.watch(contentRepositoryProvider).trail.length;
    final manual = ref.watch(persistenceServiceProvider).phase2ManuallyUnlocked;
    return manual || trailDone >= trailLength;
  }

  Future<void> unlockManually() async {
    await ref.read(persistenceServiceProvider).setPhase2ManuallyUnlocked(true);
    state = true;
  }
}

final phase2UnlockedProvider = NotifierProvider<Phase2UnlockController, bool>(
  Phase2UnlockController.new,
);
