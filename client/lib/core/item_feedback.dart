import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Regra transversal de áudio (RT-01 a RT-07, seção 4.1 da especificação) —
/// serviço ÚNICO usado por toda atividade que exibe figuras, pra regra nunca
/// divergir entre fases (RT-06). Só a política fica aqui; voz e som reais
/// (`TtsSpeechPort`, `JustAudioSoundPort`) entram por override em
/// `main.dart`, e os testes usam ports falsos — sem mudar nenhuma chamada.
/// `pad0`–`pad3`: as 4 notas do Pátio (Anexo B).
enum FeedbackSound { correct, wrong, pop, win, build, pad0, pad1, pad2, pad3 }

abstract class SpeechPort {
  /// `clear: true` = voz dedicada a nomes isolados (RT-01), mais devagar e
  /// num tom menos agudo que a fala narrativa — equivalente ao `speakName()`
  /// dos protótipos HTML. `clear: false` = fala narrativa normal (prompts,
  /// elogios, instruções).
  ///
  /// `queue: false` (padrão) = fala nova: interrompe o que estiver tocando.
  /// `queue: true` = continuação: espera a fala anterior terminar (ex.: o
  /// elogio depois do nome — o nome nunca pode ser cortado, RT-01).
  void speak(String text, {bool clear = false, bool queue = false});
}

abstract class SoundPort {
  void play(FeedbackSound sound);
}

class NoopSpeechPort implements SpeechPort {
  const NoopSpeechPort();
  @override
  void speak(String text, {bool clear = false, bool queue = false}) {}
}

class NoopSoundPort implements SoundPort {
  const NoopSoundPort();
  @override
  void play(FeedbackSound sound) {}
}

class ItemFeedback {
  const ItemFeedback({required this.speech, required this.sound});

  final SpeechPort speech;
  final SoundPort sound;

  /// RT-02 — acerto: som de acerto, fala o nome primeiro (voz clara) e
  /// depois um elogio curto. Nunca uma frase só — duas falas em sequência,
  /// pra garantir que o nome em si saia sempre inteligível.
  void correct(String name, String praise) {
    sound.play(FeedbackSound.correct);
    speech.speak(name, clear: true);
    speech.speak(praise, queue: true);
  }

  /// RT-03 — toque fora do pedido: som de erro sutil, fala o nome do que foi
  /// tocado e repete o pedido. Nunca a palavra "errou", nunca punição.
  void wrong(String tappedName, String repeatPrompt) {
    sound.play(FeedbackSound.wrong);
    speech.speak(tappedName, clear: true);
    speech.speak(repeatPrompt, queue: true);
  }

  /// RT-01 — qualquer figura tocada fora do fluxo de acerto/erro (ex.: toque
  /// de exploração num ícone) fala só o próprio nome, com a voz clara.
  /// RT-05: NUNCA chamar isto pra uma figura ainda escondida (silhueta antes
  /// de revelada) — quem decide "já pode falar" é a atividade, não aqui.
  void nameOnly(String name) {
    speech.speak(name, clear: true);
  }
}

final speechPortProvider = Provider<SpeechPort>(
  (ref) => const NoopSpeechPort(),
);
final soundPortProvider = Provider<SoundPort>((ref) => const NoopSoundPort());

final itemFeedbackProvider = Provider<ItemFeedback>(
  (ref) => ItemFeedback(
    speech: ref.watch(speechPortProvider),
    sound: ref.watch(soundPortProvider),
  ),
);
