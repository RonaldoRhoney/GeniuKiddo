import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'item_feedback.dart';
import 'persistence_service.dart';

const _sfxAssetFor = {
  FeedbackSound.correct: 'assets/sfx/good.wav',
  FeedbackSound.wrong: 'assets/sfx/oops.wav',
  FeedbackSound.pop: 'assets/sfx/pop.wav',
  FeedbackSound.win: 'assets/sfx/win.wav',
};

/// Efeitos curtos (seção 4.4): tocam SEMPRE, independente do botão de
/// música (mesmo comportamento dos protótipos — `sfx.*()` nunca passa
/// pelo `musicGain`, só a melodia de fundo é silenciável). Regra de
/// implementação obrigatória (M0): só `AudioSource.asset`, nunca
/// `setUrl`/qualquer fonte de rede.
class JustAudioSoundPort implements SoundPort {
  @override
  void play(FeedbackSound sound) {
    final asset = _sfxAssetFor[sound];
    if (asset == null) return;
    unawaited(_playOnce(asset));
  }

  Future<void> _playOnce(String asset) async {
    final player = AudioPlayer();
    try {
      await player.setAsset(asset);
      await player.play();
      // Efeito é curtíssimo (< 1s) — espera terminar e descarta o player,
      // em vez de manter um player por som vivo a aplicação inteira.
      await player.playerStateStream.firstWhere((s) => s.processingState == ProcessingState.completed);
    } catch (_) {
      // Som ausente/falha do motor de áudio nunca derruba a tela.
    } finally {
      await player.dispose();
    }
  }
}

/// Música de fundo em loop (seção 4.4): botão de silenciar sempre
/// visível, volume baixo, pausa sozinha quando o app vai pro segundo
/// plano e retoma ao voltar (só se a música estava ligada).
class MusicController extends Notifier<bool> {
  final AudioPlayer _player = AudioPlayer();
  bool _sessionReady = false;

  @override
  bool build() {
    ref.onDispose(_player.dispose);
    return ref.watch(persistenceServiceProvider).musicEnabled;
  }

  Future<void> _ensureSession() async {
    if (_sessionReady) return;
    _sessionReady = true;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _player.setAsset('assets/music/music_loop.wav');
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.35); // "volume baixo, não competir com a voz"
  }

  /// Seção 4.4: "o áudio só inicia após o primeiro toque" (web) — chamar
  /// isto no primeiro gesto real da criança (toque na splash).
  Future<void> start() async {
    await _ensureSession();
    if (state) await _player.play();
  }

  Future<void> toggle() async {
    final enabled = !state;
    await ref.read(persistenceServiceProvider).setMusicEnabled(enabled);
    state = enabled;
    await _ensureSession();
    if (enabled) {
      await _player.play();
    } else {
      await _player.pause();
    }
  }

  Future<void> pauseForBackground() async {
    if (_sessionReady) await _player.pause();
  }

  Future<void> resumeFromBackground() async {
    if (_sessionReady && state) await _player.play();
  }
}

final musicControllerProvider = NotifierProvider<MusicController, bool>(MusicController.new);
