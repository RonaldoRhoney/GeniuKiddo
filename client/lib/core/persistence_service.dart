import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento local de chave-valor (seção 4.9 da especificação):
/// idioma, música, voz, progresso — nunca nenhum identificador do usuário.
/// `shared_preferences` é local-only, sem rede (disclosure no plano do M0).
class PersistenceService {
  PersistenceService(this._prefs);

  final SharedPreferences _prefs;

  static const _kLanguageCodeKey = 'genius_kiddo_language_code_v1';

  /// `null` = app ainda não teve idioma escolhido (primeira execução).
  String? get languageCode => _prefs.getString(_kLanguageCodeKey);

  Future<void> setLanguageCode(String code) => _prefs.setString(_kLanguageCodeKey, code);
}

/// Sobrescrito em `main.dart` com a instância real, depois do
/// `SharedPreferences.getInstance()` assíncrono — nunca lido antes disso.
final persistenceServiceProvider = Provider<PersistenceService>(
  (ref) => throw UnimplementedError('persistenceServiceProvider precisa de override em main.dart'),
);
