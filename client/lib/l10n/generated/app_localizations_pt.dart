// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Genius Kiddo';

  @override
  String get appTagline => 'aprender brincando';

  @override
  String get tapToStart => 'Toque para começar';

  @override
  String get languageCardPtLabel => 'Português';

  @override
  String get languageCardEnLabel => 'English';

  @override
  String get welcomeFirst => 'Oi! Eu sou o Kiddo!';

  @override
  String get welcomeBack => 'Oi! Que bom te ver!';

  @override
  String get itemDog => 'cachorro';

  @override
  String get itemCat => 'gato';

  @override
  String get itemFish => 'peixe';

  @override
  String get itemBird => 'passarinho';

  @override
  String get itemApple => 'maçã';

  @override
  String get itemBanana => 'banana';

  @override
  String get itemCar => 'carro';

  @override
  String get itemBall => 'bola';

  @override
  String get itemSun => 'sol';

  @override
  String get colorRed => 'vermelho';

  @override
  String get colorBlue => 'azul';

  @override
  String get colorYellow => 'amarelo';

  @override
  String get colorGreen => 'verde';

  @override
  String get colorPurple => 'roxo';

  @override
  String get colorOrange => 'laranja';

  @override
  String get trailNodePaintGarden => 'Pintar o jardim';

  @override
  String get trailNodeListenAnimals => 'Ouvir os bichinhos';

  @override
  String get trailNodeMatchShadow => 'Quem é a sombra?';

  @override
  String get trailNodeTrace1 => 'Traçar o número 1';

  @override
  String get trailNodeSpeakWords => 'Repetir palavras';

  @override
  String get trailNodePaintHouse => 'Pintar a casinha';

  @override
  String get trailNodeListenFruits => 'Ouvir: frutas e coisas';

  @override
  String get trailNodeTraceO => 'Traçar a letra O';

  @override
  String get trailLocked =>
      'Ainda não! Vamos fazer a estrela brilhante primeiro!';

  @override
  String get trailFreeDraw => 'Rabisco livre';

  @override
  String get trailNewActivity =>
      'Uma nova atividade apareceu! Toque na estrela!';

  @override
  String get trailAllDone => 'Você completou a trilha! Quer brincar de novo?';

  @override
  String get trailPlayMore => 'Vamos brincar mais?';

  @override
  String get paintIntro => 'Escolha uma cor e toque no desenho!';

  @override
  String get paintDone => 'Que lindo! Você pintou tudo!';

  @override
  String traceIntro(String glyphName) {
    return 'Siga a trilha e desenhe $glyphName!';
  }

  @override
  String traceDone(String glyphName) {
    return 'Muito bem! Você desenhou $glyphName!';
  }

  @override
  String get glyphName1 => 'o número 1';

  @override
  String get glyphNameO => 'a letra O';

  @override
  String listenPrompt(String article, String name) {
    return 'Toque n$article $name!';
  }

  @override
  String get listenDone => 'Você ouviu e acertou tudo!';

  @override
  String get matchIntro => 'Quem está escondido na sombra?';

  @override
  String get matchDone => 'Você descobriu todas as sombras!';

  @override
  String speakPrompt(String name) {
    return 'Diga: $name! Agora é com você!';
  }

  @override
  String get speakDone => 'Você repetiu todas as palavras!';

  @override
  String get speakMicNote => 'O app não grava a voz da criança';

  @override
  String get speakGood => 'Muito bem! Você falou ótimo!';

  @override
  String get speakISaidIt => 'Já falei';

  @override
  String get freeDrawIntro => 'Desenhe do seu jeito!';

  @override
  String get freeDrawClear => 'limpar';

  @override
  String get freeDrawFirst => 'Desenhe um pouquinho primeiro!';

  @override
  String get freeDrawCelebrate => 'Que desenho lindo!';

  @override
  String get praise1 => 'Muito bem!';

  @override
  String get praise2 => 'Isso mesmo!';

  @override
  String get praise3 => 'Uau, que demais!';

  @override
  String get praise4 => 'Parabéns!';

  @override
  String get celebrationContinue => 'Continuar';

  @override
  String get breakMessage => 'Hora de descansar os olhinhos! Vamos beber água?';

  @override
  String get breakHoldHint => 'Peça pra um adulto segurar aqui';

  @override
  String get parentGateLabel => 'Área dos pais';

  @override
  String get parentsAreaTitle => 'Área dos pais';

  @override
  String get parentsLanguageLabel => 'Idioma';

  @override
  String get parentsSoundLabel => 'Som e voz';

  @override
  String get parentsMusicLabel => 'Música';

  @override
  String get parentsVoiceToneLabel => 'Tom da voz';

  @override
  String get parentsVoiceToneSuave => 'Suave';

  @override
  String get parentsVoiceToneFofa => 'Fofa';

  @override
  String get parentsVoiceToneSuper => 'Super fofa';

  @override
  String get parentsVoicePickLabel => 'Voz do guia';

  @override
  String get parentsVoiceAuto => 'Automática';

  @override
  String get parentsTestVoice => 'Testar a voz';

  @override
  String get parentsVoiceTestPhrase => 'Oi! Essa é a minha voz!';

  @override
  String get parentsBreakLabel => 'Pausa sugerida';

  @override
  String get parentsBreakOff => 'Desligada';

  @override
  String parentsBreakMinutes(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get parentsProgressLabel => 'Progresso';

  @override
  String parentsProgressSteps(int done, int total) {
    return '$done de $total etapas concluídas';
  }

  @override
  String parentsProgressStars(int stars) {
    return '$stars estrelas';
  }

  @override
  String get parentsAppearanceLabel => 'Aparência';

  @override
  String get parentsPrivacyLabel => 'Privacidade';

  @override
  String get parentsPrivacySummary =>
      'O Genius Kiddo não pede nome, data de nascimento nem e-mail da criança. Tudo fica guardado só neste aparelho, sem conexão com a internet, e a voz da criança nunca é gravada.';

  @override
  String get parentsPrivacyPolicyPlaceholder =>
      'A política de privacidade completa será publicada junto com o app na loja.';
}
