import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento local de chave-valor (seção 4.9 da especificação):
/// idioma, música, voz, progresso — nunca nenhum identificador do usuário.
/// `shared_preferences` é local-only, sem rede (disclosure no plano do M0).
class PersistenceService {
  PersistenceService(this._prefs);

  final SharedPreferences _prefs;

  static const _kLanguageCodeKey = 'genius_kiddo_language_code_v1';
  static const _kTrailDoneKey = 'genius_kiddo_trail_done_v1';
  static const _kStarsKey = 'genius_kiddo_stars_v1';
  static const _kThemeModeKey = 'genius_kiddo_theme_mode_v1';
  static const _kMusicEnabledKey = 'genius_kiddo_music_enabled_v1';
  static const _kVoiceEnabledKey = 'genius_kiddo_voice_enabled_v1';
  static const _kVoiceToneKey = 'genius_kiddo_voice_tone_v1';
  static const _kVoiceNamePrefix = 'genius_kiddo_voice_name_v1_';
  static const _kBreakMinutesKey = 'genius_kiddo_break_minutes_v1';
  static const _kSchoolStateKey = 'genius_kiddo_school_v1';
  static const _kPhase2UnlockedKey = 'genius_kiddo_phase2_unlocked_v1';
  static const _kWorldHintSeenKey = 'genius_kiddo_world_hint_seen_v1';

  /// `null` = app ainda não teve idioma escolhido (primeira execução).
  String? get languageCode => _prefs.getString(_kLanguageCodeKey);

  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguageCodeKey, code);

  /// Seção 4.9: progresso da Fase 1 — quantas etapas da trilha já foram
  /// concluídas (índice da próxima etapa "atual"), nenhum identificador.
  int get trailDone => _prefs.getInt(_kTrailDoneKey) ?? 0;

  Future<void> setTrailDone(int value) => _prefs.setInt(_kTrailDoneKey, value);

  int get stars => _prefs.getInt(_kStarsKey) ?? 0;

  Future<void> setStars(int value) => _prefs.setInt(_kStarsKey, value);

  /// Seção 4.7 (área dos pais): "aparência (automático, claro, escuro)".
  /// Guarda o `ThemeMode.name` ('system'|'light'|'dark') como string, não
  /// enum, pra nunca quebrar ao ler um valor salvo por versão antiga (o
  /// 'auto' antigo, ou qualquer valor desconhecido, cai em automático).
  String get themeModeName => _prefs.getString(_kThemeModeKey) ?? 'auto';

  Future<void> setThemeModeName(String value) =>
      _prefs.setString(_kThemeModeKey, value);

  /// Seção 4.4/4.7: música e voz, ligadas por padrão, botão sempre visível
  /// pra desligar.
  bool get musicEnabled => _prefs.getBool(_kMusicEnabledKey) ?? true;

  Future<void> setMusicEnabled(bool value) =>
      _prefs.setBool(_kMusicEnabledKey, value);

  bool get voiceEnabled => _prefs.getBool(_kVoiceEnabledKey) ?? true;

  Future<void> setVoiceEnabled(bool value) =>
      _prefs.setBool(_kVoiceEnabledKey, value);

  /// Seção 4.3: 'suave'|'fofa'|'super' — padrão "Fofa".
  String get voiceTone => _prefs.getString(_kVoiceToneKey) ?? 'fofa';

  Future<void> setVoiceTone(String value) =>
      _prefs.setString(_kVoiceToneKey, value);

  /// Escolha manual de voz do sistema, por idioma (seção 4.3: "escolha
  /// manual na área dos pais... preferência salva por idioma"). `null` =
  /// deixa a seleção automática escolher.
  String? voiceNameFor(String languageCode) =>
      _prefs.getString('$_kVoiceNamePrefix$languageCode');

  Future<void> setVoiceNameFor(String languageCode, String? voiceName) {
    if (voiceName == null) {
      return _prefs.remove('$_kVoiceNamePrefix$languageCode');
    }
    return _prefs.setString('$_kVoiceNamePrefix$languageCode', voiceName);
  }

  /// Seção 4.8: minutos de uso contínuo até a pausa sugerida — 0 = desligada,
  /// padrão 15.
  int get breakMinutes => _prefs.getInt(_kBreakMinutesKey) ?? 15;

  Future<void> setBreakMinutes(int value) =>
      _prefs.setInt(_kBreakMinutesKey, value);

  /// Seção 4.9: estado da escola (Fase 2) como um único JSON — estrelas,
  /// espaços e níveis, aulas, medalhas, série, objetivos resgatados.
  /// `null` = escola ainda não começou.
  String? get schoolStateJson => _prefs.getString(_kSchoolStateKey);

  Future<void> setSchoolStateJson(String value) =>
      _prefs.setString(_kSchoolStateKey, value);

  /// RF-FASE-03: pais liberaram a Fase 2 manualmente na área dos pais.
  bool get phase2ManuallyUnlocked =>
      _prefs.getBool(_kPhase2UnlockedKey) ?? false;

  Future<void> setPhase2ManuallyUnlocked(bool value) =>
      _prefs.setBool(_kPhase2UnlockedKey, value);

  /// RM-02: a mãozinha de "arraste" no mapa só aparece até a 1ª vez que a
  /// criança arrasta.
  bool get worldHintSeen => _prefs.getBool(_kWorldHintSeenKey) ?? false;

  Future<void> setWorldHintSeen() => _prefs.setBool(_kWorldHintSeenKey, true);
}

/// Sobrescrito em `main.dart` com a instância real, depois do
/// `SharedPreferences.getInstance()` assíncrono — nunca lido antes disso.
final persistenceServiceProvider = Provider<PersistenceService>(
  (ref) => throw UnimplementedError(
    'persistenceServiceProvider precisa de override em main.dart',
  ),
);
