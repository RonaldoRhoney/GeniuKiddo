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
  String get itemFlower => 'flor';

  @override
  String get itemMoon => 'lua';

  @override
  String get itemHouse => 'casa';

  @override
  String get itemGrape => 'uva';

  @override
  String get itemFrog => 'sapo';

  @override
  String get itemDuck => 'pato';

  @override
  String get itemCow => 'vaca';

  @override
  String get itemLion => 'leão';

  @override
  String get itemEgg => 'ovo';

  @override
  String get itemBee => 'abelha';

  @override
  String get itemBear => 'urso';

  @override
  String get itemStrawberry => 'morango';

  @override
  String get itemOrange => 'laranja';

  @override
  String get itemWatermelon => 'melancia';

  @override
  String get itemCarrot => 'cenoura';

  @override
  String get itemBroccoli => 'brócolis';

  @override
  String get itemPotato => 'batata';

  @override
  String get itemLettuce => 'alface';

  @override
  String get itemOnion => 'cebola';

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
  String listenPrompt(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'f': 'Toque na $name!',
      'other': 'Toque no $name!',
    });
    return '$_temp0';
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
  String get parentsThemeAuto => 'Automático';

  @override
  String get parentsThemeLight => 'Claro';

  @override
  String get parentsThemeDark => 'Escuro';

  @override
  String get parentsPrivacyLabel => 'Privacidade';

  @override
  String get parentsPrivacySummary =>
      'O Genius Kiddo não pede nome, data de nascimento nem e-mail da criança. Tudo fica guardado só neste aparelho, sem conexão com a internet, e a voz da criança nunca é gravada.';

  @override
  String get parentsPrivacyPolicyPlaceholder =>
      'A política de privacidade completa será publicada junto com o app na loja.';

  @override
  String get trailSchool => 'Escolinha';

  @override
  String get gradeGateTitle => 'Para os pais';

  @override
  String get gradeGateHint =>
      'Segure o cadeado para escolher a série da criança.';

  @override
  String get gradeChoiceTitle => 'Qual é a série?';

  @override
  String get gradeChoiceSubtitle =>
      'Escolha a série da criança. Dá para mudar depois na área dos pais.';

  @override
  String get gradeName0 => 'Maternal';

  @override
  String get gradeName1 => 'Pré I';

  @override
  String get gradeName2 => 'Pré II';

  @override
  String gradeAge(int age) {
    return '$age anos';
  }

  @override
  String get spaceName_sala => 'Sala de aula';

  @override
  String get spaceDesc_sala => 'Aqui aprendemos as formas e as cores!';

  @override
  String get spaceName_horta => 'Horta';

  @override
  String get spaceDesc_horta => 'Aqui contamos as plantinhas!';

  @override
  String get spaceName_atelie => 'Ateliê de arte';

  @override
  String get spaceDesc_atelie => 'Aqui pintamos desenhos lindos!';

  @override
  String get spaceName_biblio => 'Biblioteca';

  @override
  String get spaceDesc_biblio => 'Aqui descobrimos as letras!';

  @override
  String get spaceName_patio => 'Pátio';

  @override
  String get spaceDesc_patio => 'Aqui brincamos de repetir os sons!';

  @override
  String get spaceName_refeit => 'Refeitório';

  @override
  String get spaceDesc_refeit => 'Aqui separamos frutas e legumes!';

  @override
  String get schoolWelcomeFirst =>
      'Bem-vindo à nossa escolinha! Toque na sala de aula!';

  @override
  String get schoolWelcomeBack =>
      'Oi! Que bom te ver! Vamos cuidar da nossa escola?';

  @override
  String get schoolHintGoal => 'Você cumpriu um objetivo! Toque no troféu!';

  @override
  String get schoolHintStars => 'Você tem estrelas! Toque no espaço brilhante!';

  @override
  String get schoolHintLesson =>
      'Toque num espaço para ter aula e ganhar estrelas!';

  @override
  String schoolGradeLocked(String grade) {
    return 'Esse espaço chega no $grade! Vamos passar de ano!';
  }

  @override
  String get schoolBuild => 'Construir';

  @override
  String get schoolUpgrade => 'Melhorar';

  @override
  String get schoolLesson => 'Ter aula';

  @override
  String get schoolEarnStars => 'Ganhar estrelas';

  @override
  String get schoolMaxed => 'Espaço no máximo! 🌟';

  @override
  String get schoolClose => 'Fechar';

  @override
  String get schoolBuilt => 'Que lindo! Nossa escola cresceu!';

  @override
  String get schoolUpgraded => 'Uau! Ficou ainda melhor!';

  @override
  String get schoolNeedStars => 'Faça uma aula para ganhar estrelas!';

  @override
  String get schoolLessonDone => 'Você ganhou estrelas!';

  @override
  String schoolKidsLabel(int count) {
    return '$count alunos na escola';
  }

  @override
  String get goalsButton => 'Objetivos';

  @override
  String goalsTitle(String grade) {
    return 'Objetivos do $grade';
  }

  @override
  String missionBuild(int n) {
    return 'Construir $n espaços';
  }

  @override
  String missionLessons(int n) {
    return 'Fazer $n aulas';
  }

  @override
  String missionUpgrade(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Melhorar $n espaços',
      one: 'Melhorar um espaço',
    );
    return '$_temp0';
  }

  @override
  String missionMax(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Deixar $n espaços no máximo',
      one: 'Deixar um espaço no máximo',
    );
    return '$_temp0';
  }

  @override
  String get goalClaim => 'Pegar';

  @override
  String get medalEarned => 'Medalha conquistada! Parabéns!';

  @override
  String get promoteButton => 'Passar de ano';

  @override
  String get graduateButton => 'Formatura';

  @override
  String get graduatedBadge => 'Formatura!';

  @override
  String promoted(String grade) {
    return 'Parabéns! Agora você está no $grade! Chegaram espaços novos!';
  }

  @override
  String get graduated =>
      'Formatura! Você completou a escolinha! Em breve: 1º ano!';

  @override
  String get afterPromotion => 'Toque no espaço novo que está brilhando!';

  @override
  String get afterGraduation => 'Vamos brincar mais na nossa escola?';

  @override
  String get graduationDoneNote => '🎓 Formatura concluída! Em breve: 1º ano.';

  @override
  String get parentsSchoolLabel => 'Escolinha';

  @override
  String get parentsSchoolLockedHint =>
      'A Escolinha abre quando a criança termina as etapas da trilha.';

  @override
  String get parentsUnlockSchool => 'Liberar a Escolinha agora';

  @override
  String get parentsGradeLabel => 'Série da criança';

  @override
  String get parentsGradeChangeNote =>
      'Trocar a série não apaga o que foi construído; os objetivos do ano recomeçam.';

  @override
  String parentsSchoolProgress(int stars, int medals) {
    return '$stars estrelas na escola · $medals medalhas';
  }

  @override
  String get shapeCircle => 'círculo';

  @override
  String get shapeSquare => 'quadrado';

  @override
  String get shapeTriangle => 'triângulo';

  @override
  String get shapeStar => 'estrela';

  @override
  String get shapeHeart => 'coração';

  @override
  String colorRedFor(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'f': 'vermelha',
      'other': 'vermelho',
    });
    return '$_temp0';
  }

  @override
  String colorBlueFor(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {'other': 'azul'});
    return '$_temp0';
  }

  @override
  String colorYellowFor(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'f': 'amarela',
      'other': 'amarelo',
    });
    return '$_temp0';
  }

  @override
  String colorGreenFor(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {'other': 'verde'});
    return '$_temp0';
  }

  @override
  String colorPurpleFor(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'f': 'roxa',
      'other': 'roxo',
    });
    return '$_temp0';
  }

  @override
  String shapeWithColor(String shape, String color) {
    return '$shape $color';
  }

  @override
  String get shapesDone => 'Você conhece as formas!';

  @override
  String get countIntro => 'Toque nas plantinhas e conte! Quantas são?';

  @override
  String get countRetry => 'Conte as plantinhas de novo!';

  @override
  String get countNumbers =>
      'zero,um,dois,três,quatro,cinco,seis,sete,oito,nove,dez';

  @override
  String get countPlant => 'plantinha';

  @override
  String get countDone => 'Você contou tudo!';

  @override
  String lettersPrompt(String name) {
    return '$name! Com qual letra começa?';
  }

  @override
  String lettersCorrect(String praise, String letter) {
    return '$praise Começa com $letter!';
  }

  @override
  String get lettersDone => 'Você descobriu as letras!';

  @override
  String get letterFold => 'á=a,à=a,â=a,ã=a,é=e,ê=e,í=i,ó=o,ô=o,õ=o,ú=u,ç=c';

  @override
  String get rhythmWatch => 'Olhe e escute!';

  @override
  String get rhythmTurn => 'Sua vez!';

  @override
  String get rhythmRetry => 'Quase! Vamos ouvir de novo!';

  @override
  String get rhythmNote => 'Olhe, escute e repita a sequência!';

  @override
  String rhythmPad(int n) {
    return 'Botão $n';
  }

  @override
  String get rhythmDone => 'Que música bonita!';

  @override
  String sortPrompt(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'f': 'Onde vai a $name? Frutas ou legumes?',
      'other': 'Onde vai o $name? Frutas ou legumes?',
    });
    return '$_temp0';
  }

  @override
  String get sortRetry => 'Frutas ou legumes?';

  @override
  String get sortFruits => 'Frutas';

  @override
  String get sortVeggies => 'Legumes';

  @override
  String get sortDone => 'Tudo separadinho!';

  @override
  String get musicOn => 'Música ligada';

  @override
  String get musicOff => 'Música desligada';

  @override
  String schoolLotLevel(String name, int level, int max) {
    return '$name, nível $level de $max';
  }

  @override
  String schoolLotEmpty(String name, int cost) {
    return '$name, vazio, construir por $cost estrelas';
  }

  @override
  String schoolLotLocked(String name, String grade) {
    return '$name, chega no $grade';
  }

  @override
  String schoolLockedPrev(String name) {
    return 'Ainda não! Primeiro: $name.';
  }

  @override
  String schoolNextLesson(String name) {
    return 'A próxima aula é: $name!';
  }

  @override
  String schoolLotSequenceLocked(String name) {
    return '$name, trancado';
  }

  @override
  String get missionLocked => 'Trancado — resgate o objetivo anterior primeiro';

  @override
  String get homeTrail => 'Trilha';

  @override
  String homeTrailProgress(int done, int total) {
    return '$done de $total';
  }

  @override
  String get homeSchoolLocked =>
      'A Escolinha abre quando você terminar a trilha!';

  @override
  String get trailHint => 'Toque na estrela brilhante!';

  @override
  String get homeButton => 'Início';

  @override
  String get parentsExitLabel => 'Sair do app';

  @override
  String get parentsExitHint =>
      'Fecha o Genius Kiddo. O progresso fica salvo neste aparelho.';

  @override
  String get worldGoToGlow => 'Ir ao espaço brilhante';

  @override
  String get worldDragHint => 'Arraste o dedo para ver a escola!';
}
