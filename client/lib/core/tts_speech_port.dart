import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'item_feedback.dart';
import 'language_controller.dart';
import 'persistence_service.dart';

/// Tons de voz (Anexo A / seção 4.3): [pitch, velocidade-relativa-web]. O
/// pitch do `flutter_tts` usa a MESMA escala 0.5-2.0 da Web Speech API
/// (1.0 = normal), então os valores do documento vão direto. A velocidade
/// do `flutter_tts` é normalizada 0.0-1.0 (~0.5 = normal nas duas
/// plataformas), então convertemos a velocidade "relativa à fala normal"
/// do documento (0.90-0.95, perto de 1.0) multiplicando por 0.5.
const _tones = {
  'suave': (pitch: 1.45, webRate: 0.95),
  'fofa': (pitch: 1.75, webRate: 0.92),
  'super': (pitch: 1.95, webRate: 0.90),
};

double _ttsRate(double webRate) => (webRate * 0.5).clamp(0.1, 1.0);

/// Voz do guia via síntese do sistema (ADR-008: MVP usa a voz nativa do
/// aparelho; clipe gravado entra no M8 — ver seção 4.3 "fallback de voz").
/// `clear: true` (RT-01, nomes isolados) usa um pitch/velocidade fixos,
/// mais devagar e menos agudo que a fala narrativa, pra garantir clareza
/// máxima — mesma ideia do `speakName()` dos protótipos HTML.
class TtsSpeechPort implements SpeechPort {
  TtsSpeechPort(this._tts, this._ref);

  final FlutterTts _tts;
  final Ref _ref;

  static const _clearPitch = 1.3;
  static const _clearWebRate = 0.8;

  List<Map<Object?, Object?>>? _cachedVoices;

  @override
  void speak(String text, {bool clear = false}) {
    // fire-and-forget de propósito: a UI nunca espera a fala terminar pra
    // continuar (mesmo padrão dos protótipos — `speak()`/`speakRaw()`
    // síncronos do ponto de vista de quem chama).
    unawaited(_speak(text, clear: clear));
  }

  Future<void> _speak(String text, {required bool clear}) async {
    final persistence = _ref.read(persistenceServiceProvider);
    if (!persistence.voiceEnabled) return;

    final languageCode = _ref.read(languageControllerProvider).code ?? 'pt';
    final locale = languageCode == 'en' ? 'en-US' : 'pt-BR';

    final tone = _tones[persistence.voiceTone] ?? _tones['fofa']!;
    final pitch = clear ? _clearPitch : tone.pitch;
    final webRate = clear ? _clearWebRate : tone.webRate;

    try {
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.setPitch(pitch);
      await _tts.setSpeechRate(_ttsRate(webRate));
      await _setPreferredVoice(locale, languageCode, persistence);
      await _tts.speak(text);
    } catch (_) {
      // Seção 4.3: "algumas vozes do sistema ignoram o pitch. É esperado."
      // Qualquer falha de síntese (motor ausente, parâmetro rejeitado)
      // nunca derruba a tela — a criança só não ouve a fala desta vez.
    }
  }

  Future<void> _setPreferredVoice(
    String locale,
    String languageCode,
    PersistenceService persistence,
  ) async {
    final voices = await _voicesFor(locale);
    if (voices.isEmpty) return;

    final chosenName = persistence.voiceNameFor(languageCode);
    Map<Object?, Object?>? pick;
    if (chosenName != null) {
      pick = voices.where((v) => v['name'] == chosenName).firstOrNull;
    }
    pick ??= _bestAutomaticVoice(voices, locale);
    if (pick == null) return;
    await _tts.setVoice({
      'name': pick['name'] as String,
      'locale': pick['locale'] as String,
    });
  }

  /// Seção 4.3: "seleção automática... preferência por vozes femininas,
  /// claras e jovens" — mesma lista curada dos protótipos HTML.
  static const _preferredNames = {
    'pt-BR': [
      'Luciana',
      'Google português do Brasil',
      'Francisca',
      'Maria',
      'Fernanda',
      'Vitória',
      'Camila',
    ],
    'en-US': [
      'Samantha',
      'Kathy',
      'Ava',
      'Allison',
      'Google US English',
      'Aria',
      'Jenny',
      'Zira',
      'Susan',
    ],
  };

  Map<Object?, Object?>? _bestAutomaticVoice(
    List<Map<Object?, Object?>> voices,
    String locale,
  ) {
    for (final preferred in _preferredNames[locale] ?? const []) {
      final match = voices
          .where((v) => (v['name'] as String? ?? '').contains(preferred))
          .firstOrNull;
      if (match != null) return match;
    }
    return voices.first;
  }

  Future<List<Map<Object?, Object?>>> _voicesFor(String locale) async {
    if (_cachedVoices == null) {
      try {
        final raw = await _tts.getVoices as List?;
        _cachedVoices = raw?.cast<Map<Object?, Object?>>() ?? const [];
      } catch (_) {
        _cachedVoices = const [];
      }
    }
    final base = locale.split('-').first;
    return _cachedVoices!
        .where(
          (v) => (v['locale'] as String? ?? '').toLowerCase().startsWith(base),
        )
        .toList();
  }

  /// Exposto pra área dos pais (M4) listar e escolher a voz manualmente —
  /// mesma ideia do seletor de voz com botão "Testar a voz" dos protótipos.
  Future<List<Map<Object?, Object?>>> voicesForCurrentLanguage() async {
    final languageCode = _ref.read(languageControllerProvider).code ?? 'pt';
    final locale = languageCode == 'en' ? 'en-US' : 'pt-BR';
    return _voicesFor(locale);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
