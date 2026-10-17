import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Nome do app, exibido na splash. Nome de marca, nunca traduzido (seção 1.1 item 2 da especificação).
  ///
  /// In pt, this message translates to:
  /// **'Genius Kiddo'**
  String get appTitle;

  /// Subtítulo curto na tela de splash
  ///
  /// In pt, this message translates to:
  /// **'aprender brincando'**
  String get appTagline;

  /// Convite de toque na splash
  ///
  /// In pt, this message translates to:
  /// **'Toque para começar'**
  String get tapToStart;

  /// Fala do guia na primeira execução, logo após escolher o idioma (Anexo C, welcome.first)
  ///
  /// In pt, this message translates to:
  /// **'Oi! Eu sou o Kiddo!'**
  String get welcomeFirst;

  /// Fala do guia quando o app já tem idioma salvo (Anexo C, welcome.back)
  ///
  /// In pt, this message translates to:
  /// **'Oi! Que bom te ver!'**
  String get welcomeBack;

  /// No description provided for @itemDog.
  ///
  /// In pt, this message translates to:
  /// **'cachorro'**
  String get itemDog;

  /// No description provided for @itemCat.
  ///
  /// In pt, this message translates to:
  /// **'gato'**
  String get itemCat;

  /// No description provided for @itemFish.
  ///
  /// In pt, this message translates to:
  /// **'peixe'**
  String get itemFish;

  /// No description provided for @itemBird.
  ///
  /// In pt, this message translates to:
  /// **'passarinho'**
  String get itemBird;

  /// No description provided for @itemApple.
  ///
  /// In pt, this message translates to:
  /// **'maçã'**
  String get itemApple;

  /// No description provided for @itemBanana.
  ///
  /// In pt, this message translates to:
  /// **'banana'**
  String get itemBanana;

  /// No description provided for @itemCar.
  ///
  /// In pt, this message translates to:
  /// **'carro'**
  String get itemCar;

  /// No description provided for @itemBall.
  ///
  /// In pt, this message translates to:
  /// **'bola'**
  String get itemBall;

  /// No description provided for @itemSun.
  ///
  /// In pt, this message translates to:
  /// **'sol'**
  String get itemSun;

  /// No description provided for @itemFlower.
  ///
  /// In pt, this message translates to:
  /// **'flor'**
  String get itemFlower;

  /// No description provided for @itemMoon.
  ///
  /// In pt, this message translates to:
  /// **'lua'**
  String get itemMoon;

  /// No description provided for @itemHouse.
  ///
  /// In pt, this message translates to:
  /// **'casa'**
  String get itemHouse;

  /// No description provided for @itemGrape.
  ///
  /// In pt, this message translates to:
  /// **'uva'**
  String get itemGrape;

  /// No description provided for @itemFrog.
  ///
  /// In pt, this message translates to:
  /// **'sapo'**
  String get itemFrog;

  /// No description provided for @itemDuck.
  ///
  /// In pt, this message translates to:
  /// **'pato'**
  String get itemDuck;

  /// No description provided for @itemCow.
  ///
  /// In pt, this message translates to:
  /// **'vaca'**
  String get itemCow;

  /// No description provided for @itemLion.
  ///
  /// In pt, this message translates to:
  /// **'leão'**
  String get itemLion;

  /// No description provided for @itemEgg.
  ///
  /// In pt, this message translates to:
  /// **'ovo'**
  String get itemEgg;

  /// No description provided for @itemBee.
  ///
  /// In pt, this message translates to:
  /// **'abelha'**
  String get itemBee;

  /// No description provided for @itemBear.
  ///
  /// In pt, this message translates to:
  /// **'urso'**
  String get itemBear;

  /// No description provided for @itemStrawberry.
  ///
  /// In pt, this message translates to:
  /// **'morango'**
  String get itemStrawberry;

  /// No description provided for @itemOrange.
  ///
  /// In pt, this message translates to:
  /// **'laranja'**
  String get itemOrange;

  /// No description provided for @itemWatermelon.
  ///
  /// In pt, this message translates to:
  /// **'melancia'**
  String get itemWatermelon;

  /// No description provided for @itemCarrot.
  ///
  /// In pt, this message translates to:
  /// **'cenoura'**
  String get itemCarrot;

  /// No description provided for @itemBroccoli.
  ///
  /// In pt, this message translates to:
  /// **'brócolis'**
  String get itemBroccoli;

  /// No description provided for @itemPotato.
  ///
  /// In pt, this message translates to:
  /// **'batata'**
  String get itemPotato;

  /// No description provided for @itemLettuce.
  ///
  /// In pt, this message translates to:
  /// **'alface'**
  String get itemLettuce;

  /// No description provided for @itemOnion.
  ///
  /// In pt, this message translates to:
  /// **'cebola'**
  String get itemOnion;

  /// No description provided for @colorRed.
  ///
  /// In pt, this message translates to:
  /// **'vermelho'**
  String get colorRed;

  /// No description provided for @colorBlue.
  ///
  /// In pt, this message translates to:
  /// **'azul'**
  String get colorBlue;

  /// No description provided for @colorYellow.
  ///
  /// In pt, this message translates to:
  /// **'amarelo'**
  String get colorYellow;

  /// No description provided for @colorGreen.
  ///
  /// In pt, this message translates to:
  /// **'verde'**
  String get colorGreen;

  /// No description provided for @colorPurple.
  ///
  /// In pt, this message translates to:
  /// **'roxo'**
  String get colorPurple;

  /// No description provided for @colorOrange.
  ///
  /// In pt, this message translates to:
  /// **'laranja'**
  String get colorOrange;

  /// No description provided for @trailNodePaintGarden.
  ///
  /// In pt, this message translates to:
  /// **'Pintar o jardim'**
  String get trailNodePaintGarden;

  /// No description provided for @trailNodeListenAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir os bichinhos'**
  String get trailNodeListenAnimals;

  /// No description provided for @trailNodeMatchShadow.
  ///
  /// In pt, this message translates to:
  /// **'Quem é a sombra?'**
  String get trailNodeMatchShadow;

  /// No description provided for @trailNodeTrace1.
  ///
  /// In pt, this message translates to:
  /// **'Traçar o número 1'**
  String get trailNodeTrace1;

  /// No description provided for @trailNodeSpeakWords.
  ///
  /// In pt, this message translates to:
  /// **'Repetir palavras'**
  String get trailNodeSpeakWords;

  /// No description provided for @trailNodePaintHouse.
  ///
  /// In pt, this message translates to:
  /// **'Pintar a casinha'**
  String get trailNodePaintHouse;

  /// No description provided for @trailNodeListenFruits.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir: frutas e coisas'**
  String get trailNodeListenFruits;

  /// No description provided for @trailNodeTraceO.
  ///
  /// In pt, this message translates to:
  /// **'Traçar a letra O'**
  String get trailNodeTraceO;

  /// RT: fala ao tocar numa etapa ainda bloqueada
  ///
  /// In pt, this message translates to:
  /// **'Ainda não! Vamos fazer a estrela brilhante primeiro!'**
  String get trailLocked;

  /// No description provided for @trailFreeDraw.
  ///
  /// In pt, this message translates to:
  /// **'Rabisco livre'**
  String get trailFreeDraw;

  /// No description provided for @trailNewActivity.
  ///
  /// In pt, this message translates to:
  /// **'Uma nova atividade apareceu! Toque na estrela!'**
  String get trailNewActivity;

  /// No description provided for @trailAllDone.
  ///
  /// In pt, this message translates to:
  /// **'Você completou a trilha! Quer brincar de novo?'**
  String get trailAllDone;

  /// No description provided for @trailPlayMore.
  ///
  /// In pt, this message translates to:
  /// **'Vamos brincar mais?'**
  String get trailPlayMore;

  /// No description provided for @paintIntro.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma cor e toque no desenho!'**
  String get paintIntro;

  /// No description provided for @paintDone.
  ///
  /// In pt, this message translates to:
  /// **'Que lindo! Você pintou tudo!'**
  String get paintDone;

  /// No description provided for @traceIntro.
  ///
  /// In pt, this message translates to:
  /// **'Siga a trilha e desenhe {glyphName}!'**
  String traceIntro(String glyphName);

  /// No description provided for @traceDone.
  ///
  /// In pt, this message translates to:
  /// **'Muito bem! Você desenhou {glyphName}!'**
  String traceDone(String glyphName);

  /// No description provided for @glyphName1.
  ///
  /// In pt, this message translates to:
  /// **'o número 1'**
  String get glyphName1;

  /// No description provided for @glyphNameO.
  ///
  /// In pt, this message translates to:
  /// **'a letra O'**
  String get glyphNameO;

  /// gender = gênero do item no idioma (m/f/other, de items.json) — cada idioma escolhe o artigo
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, f{Toque na {name}!} other{Toque no {name}!}}'**
  String listenPrompt(String gender, String name);

  /// No description provided for @listenDone.
  ///
  /// In pt, this message translates to:
  /// **'Você ouviu e acertou tudo!'**
  String get listenDone;

  /// No description provided for @matchIntro.
  ///
  /// In pt, this message translates to:
  /// **'Quem está escondido na sombra?'**
  String get matchIntro;

  /// No description provided for @matchDone.
  ///
  /// In pt, this message translates to:
  /// **'Você descobriu todas as sombras!'**
  String get matchDone;

  /// No description provided for @speakPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Diga: {name}! Agora é com você!'**
  String speakPrompt(String name);

  /// No description provided for @speakDone.
  ///
  /// In pt, this message translates to:
  /// **'Você repetiu todas as palavras!'**
  String get speakDone;

  /// No description provided for @speakMicNote.
  ///
  /// In pt, this message translates to:
  /// **'O app não grava a voz da criança'**
  String get speakMicNote;

  /// No description provided for @speakGood.
  ///
  /// In pt, this message translates to:
  /// **'Muito bem! Você falou ótimo!'**
  String get speakGood;

  /// No description provided for @speakISaidIt.
  ///
  /// In pt, this message translates to:
  /// **'Já falei'**
  String get speakISaidIt;

  /// No description provided for @freeDrawIntro.
  ///
  /// In pt, this message translates to:
  /// **'Desenhe do seu jeito!'**
  String get freeDrawIntro;

  /// No description provided for @freeDrawClear.
  ///
  /// In pt, this message translates to:
  /// **'limpar'**
  String get freeDrawClear;

  /// RT-08 (Anexo C, free.first): fala ao tocar no botão ✓ com a tela ainda em branco
  ///
  /// In pt, this message translates to:
  /// **'Desenhe um pouquinho primeiro!'**
  String get freeDrawFirst;

  /// RT-08 (Anexo C, free.done): mensagem da celebração curta ao tocar no botão ✓ depois de desenhar
  ///
  /// In pt, this message translates to:
  /// **'Que desenho lindo!'**
  String get freeDrawCelebrate;

  /// No description provided for @praise1.
  ///
  /// In pt, this message translates to:
  /// **'Muito bem!'**
  String get praise1;

  /// No description provided for @praise2.
  ///
  /// In pt, this message translates to:
  /// **'Isso mesmo!'**
  String get praise2;

  /// No description provided for @praise3.
  ///
  /// In pt, this message translates to:
  /// **'Uau, que demais!'**
  String get praise3;

  /// No description provided for @praise4.
  ///
  /// In pt, this message translates to:
  /// **'Parabéns!'**
  String get praise4;

  /// No description provided for @celebrationContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get celebrationContinue;

  /// Seção 4.8: fala/texto da pausa sugerida
  ///
  /// In pt, this message translates to:
  /// **'Hora de descansar os olhinhos! Vamos beber água?'**
  String get breakMessage;

  /// Dica sob o cadeado da sobreposição de pausa, pra um adulto saber como dispensar
  ///
  /// In pt, this message translates to:
  /// **'Peça pra um adulto segurar aqui'**
  String get breakHoldHint;

  /// Rótulo semântico (acessibilidade) do cadeado discreto — nunca exibido como texto visível na tela da criança
  ///
  /// In pt, this message translates to:
  /// **'Controle dos pais'**
  String get parentGateLabel;

  /// No description provided for @parentsAreaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle dos pais'**
  String get parentsAreaTitle;

  /// No description provided for @parentsLanguageLabel.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get parentsLanguageLabel;

  /// No description provided for @parentsSoundLabel.
  ///
  /// In pt, this message translates to:
  /// **'Som e voz'**
  String get parentsSoundLabel;

  /// No description provided for @parentsMusicLabel.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get parentsMusicLabel;

  /// No description provided for @parentsVoiceToneLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tom da voz'**
  String get parentsVoiceToneLabel;

  /// No description provided for @parentsVoiceToneSuave.
  ///
  /// In pt, this message translates to:
  /// **'Suave'**
  String get parentsVoiceToneSuave;

  /// No description provided for @parentsVoiceToneFofa.
  ///
  /// In pt, this message translates to:
  /// **'Fofa'**
  String get parentsVoiceToneFofa;

  /// No description provided for @parentsVoiceToneSuper.
  ///
  /// In pt, this message translates to:
  /// **'Super fofa'**
  String get parentsVoiceToneSuper;

  /// No description provided for @parentsVoicePickLabel.
  ///
  /// In pt, this message translates to:
  /// **'Voz do guia'**
  String get parentsVoicePickLabel;

  /// No description provided for @parentsVoiceAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automática'**
  String get parentsVoiceAuto;

  /// No description provided for @parentsTestVoice.
  ///
  /// In pt, this message translates to:
  /// **'Testar a voz'**
  String get parentsTestVoice;

  /// Frase falada pelo botão "Testar a voz" na área dos pais
  ///
  /// In pt, this message translates to:
  /// **'Oi! Essa é a minha voz!'**
  String get parentsVoiceTestPhrase;

  /// No description provided for @parentsBreakLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pausa sugerida'**
  String get parentsBreakLabel;

  /// No description provided for @parentsBreakOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligada'**
  String get parentsBreakOff;

  /// No description provided for @parentsBreakMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} minutos'**
  String parentsBreakMinutes(int minutes);

  /// No description provided for @parentsProgressLabel.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get parentsProgressLabel;

  /// No description provided for @parentsProgressSteps.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} etapas concluídas'**
  String parentsProgressSteps(int done, int total);

  /// No description provided for @parentsProgressStars.
  ///
  /// In pt, this message translates to:
  /// **'{stars} estrelas'**
  String parentsProgressStars(int stars);

  /// No description provided for @parentsAppearanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get parentsAppearanceLabel;

  /// No description provided for @parentsThemeAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get parentsThemeAuto;

  /// No description provided for @parentsThemeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get parentsThemeLight;

  /// No description provided for @parentsThemeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get parentsThemeDark;

  /// No description provided for @parentsPrivacyLabel.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get parentsPrivacyLabel;

  /// No description provided for @parentsPrivacySummary.
  ///
  /// In pt, this message translates to:
  /// **'O Genius Kiddo não pede nome, data de nascimento nem e-mail da criança. Tudo fica guardado só neste aparelho, sem conexão com a internet, e a voz da criança nunca é gravada.'**
  String get parentsPrivacySummary;

  /// No description provided for @trailSchool.
  ///
  /// In pt, this message translates to:
  /// **'Escolinha'**
  String get trailSchool;

  /// No description provided for @gradeGateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Para os pais'**
  String get gradeGateTitle;

  /// No description provided for @gradeGateHint.
  ///
  /// In pt, this message translates to:
  /// **'Segure o cadeado para escolher a série da criança.'**
  String get gradeGateHint;

  /// No description provided for @gradeChoiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é a série?'**
  String get gradeChoiceTitle;

  /// No description provided for @gradeChoiceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a série da criança. Dá para mudar depois na área dos pais.'**
  String get gradeChoiceSubtitle;

  /// No description provided for @gradeName0.
  ///
  /// In pt, this message translates to:
  /// **'Maternal'**
  String get gradeName0;

  /// No description provided for @gradeName1.
  ///
  /// In pt, this message translates to:
  /// **'Pré I'**
  String get gradeName1;

  /// No description provided for @gradeName2.
  ///
  /// In pt, this message translates to:
  /// **'Pré II'**
  String get gradeName2;

  /// No description provided for @gradeAge.
  ///
  /// In pt, this message translates to:
  /// **'{age} anos'**
  String gradeAge(int age);

  /// No description provided for @spaceName_sala.
  ///
  /// In pt, this message translates to:
  /// **'Sala de aula'**
  String get spaceName_sala;

  /// No description provided for @spaceDesc_sala.
  ///
  /// In pt, this message translates to:
  /// **'Aqui aprendemos as formas e as cores!'**
  String get spaceDesc_sala;

  /// No description provided for @spaceName_horta.
  ///
  /// In pt, this message translates to:
  /// **'Horta'**
  String get spaceName_horta;

  /// No description provided for @spaceDesc_horta.
  ///
  /// In pt, this message translates to:
  /// **'Aqui contamos as plantinhas!'**
  String get spaceDesc_horta;

  /// No description provided for @spaceName_atelie.
  ///
  /// In pt, this message translates to:
  /// **'Ateliê de arte'**
  String get spaceName_atelie;

  /// No description provided for @spaceDesc_atelie.
  ///
  /// In pt, this message translates to:
  /// **'Aqui pintamos desenhos lindos!'**
  String get spaceDesc_atelie;

  /// No description provided for @spaceName_biblio.
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca'**
  String get spaceName_biblio;

  /// No description provided for @spaceDesc_biblio.
  ///
  /// In pt, this message translates to:
  /// **'Aqui descobrimos as letras!'**
  String get spaceDesc_biblio;

  /// No description provided for @spaceName_patio.
  ///
  /// In pt, this message translates to:
  /// **'Pátio'**
  String get spaceName_patio;

  /// No description provided for @spaceDesc_patio.
  ///
  /// In pt, this message translates to:
  /// **'Aqui brincamos de repetir os sons!'**
  String get spaceDesc_patio;

  /// No description provided for @spaceName_refeit.
  ///
  /// In pt, this message translates to:
  /// **'Refeitório'**
  String get spaceName_refeit;

  /// No description provided for @spaceDesc_refeit.
  ///
  /// In pt, this message translates to:
  /// **'Aqui separamos frutas e legumes!'**
  String get spaceDesc_refeit;

  /// No description provided for @schoolWelcomeFirst.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo à nossa escolinha! Toque na sala de aula!'**
  String get schoolWelcomeFirst;

  /// No description provided for @schoolWelcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Oi! Que bom te ver! Vamos cuidar da nossa escola?'**
  String get schoolWelcomeBack;

  /// No description provided for @schoolHintGoal.
  ///
  /// In pt, this message translates to:
  /// **'Você cumpriu um objetivo! Toque no troféu!'**
  String get schoolHintGoal;

  /// No description provided for @schoolHintStars.
  ///
  /// In pt, this message translates to:
  /// **'Você tem estrelas! Toque no espaço brilhante!'**
  String get schoolHintStars;

  /// No description provided for @schoolHintLesson.
  ///
  /// In pt, this message translates to:
  /// **'Toque num espaço para ter aula e ganhar estrelas!'**
  String get schoolHintLesson;

  /// No description provided for @schoolGradeLocked.
  ///
  /// In pt, this message translates to:
  /// **'Esse espaço chega no {grade}! Vamos passar de ano!'**
  String schoolGradeLocked(String grade);

  /// No description provided for @schoolBuild.
  ///
  /// In pt, this message translates to:
  /// **'Construir'**
  String get schoolBuild;

  /// No description provided for @schoolUpgrade.
  ///
  /// In pt, this message translates to:
  /// **'Melhorar'**
  String get schoolUpgrade;

  /// No description provided for @schoolLesson.
  ///
  /// In pt, this message translates to:
  /// **'Ter aula'**
  String get schoolLesson;

  /// No description provided for @schoolEarnStars.
  ///
  /// In pt, this message translates to:
  /// **'Ganhar estrelas'**
  String get schoolEarnStars;

  /// No description provided for @schoolMaxed.
  ///
  /// In pt, this message translates to:
  /// **'Espaço no máximo! 🌟'**
  String get schoolMaxed;

  /// No description provided for @schoolClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get schoolClose;

  /// No description provided for @schoolBuilt.
  ///
  /// In pt, this message translates to:
  /// **'Que lindo! Nossa escola cresceu!'**
  String get schoolBuilt;

  /// No description provided for @schoolUpgraded.
  ///
  /// In pt, this message translates to:
  /// **'Uau! Ficou ainda melhor!'**
  String get schoolUpgraded;

  /// No description provided for @schoolNeedStars.
  ///
  /// In pt, this message translates to:
  /// **'Faça uma aula para ganhar estrelas!'**
  String get schoolNeedStars;

  /// No description provided for @goalsButton.
  ///
  /// In pt, this message translates to:
  /// **'Objetivos'**
  String get goalsButton;

  /// No description provided for @goalsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Objetivos do {grade}'**
  String goalsTitle(String grade);

  /// No description provided for @missionBuild.
  ///
  /// In pt, this message translates to:
  /// **'Construir {n} espaços'**
  String missionBuild(int n);

  /// No description provided for @missionLessons.
  ///
  /// In pt, this message translates to:
  /// **'Fazer {n} aulas'**
  String missionLessons(int n);

  /// No description provided for @missionUpgrade.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Melhorar um espaço} other{Melhorar {n} espaços}}'**
  String missionUpgrade(int n);

  /// No description provided for @missionMax.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Deixar um espaço no máximo} other{Deixar {n} espaços no máximo}}'**
  String missionMax(int n);

  /// No description provided for @goalClaim.
  ///
  /// In pt, this message translates to:
  /// **'Pegar'**
  String get goalClaim;

  /// No description provided for @medalEarned.
  ///
  /// In pt, this message translates to:
  /// **'Medalha conquistada! Parabéns!'**
  String get medalEarned;

  /// No description provided for @promoteButton.
  ///
  /// In pt, this message translates to:
  /// **'Passar de ano'**
  String get promoteButton;

  /// No description provided for @graduateButton.
  ///
  /// In pt, this message translates to:
  /// **'Formatura'**
  String get graduateButton;

  /// No description provided for @graduatedBadge.
  ///
  /// In pt, this message translates to:
  /// **'Formatura!'**
  String get graduatedBadge;

  /// No description provided for @promoted.
  ///
  /// In pt, this message translates to:
  /// **'Parabéns! Agora você está no {grade}! Chegaram espaços novos!'**
  String promoted(String grade);

  /// No description provided for @graduated.
  ///
  /// In pt, this message translates to:
  /// **'Formatura! Você completou a escolinha! Em breve: 1º ano!'**
  String get graduated;

  /// No description provided for @afterPromotion.
  ///
  /// In pt, this message translates to:
  /// **'Toque no espaço novo que está brilhando!'**
  String get afterPromotion;

  /// No description provided for @afterGraduation.
  ///
  /// In pt, this message translates to:
  /// **'Vamos brincar mais na nossa escola?'**
  String get afterGraduation;

  /// No description provided for @graduationDoneNote.
  ///
  /// In pt, this message translates to:
  /// **'🎓 Formatura concluída! Em breve: 1º ano.'**
  String get graduationDoneNote;

  /// No description provided for @parentsSchoolLabel.
  ///
  /// In pt, this message translates to:
  /// **'Escolinha'**
  String get parentsSchoolLabel;

  /// No description provided for @parentsSchoolLockedHint.
  ///
  /// In pt, this message translates to:
  /// **'A Escolinha abre quando a criança termina as etapas da trilha.'**
  String get parentsSchoolLockedHint;

  /// No description provided for @parentsUnlockSchool.
  ///
  /// In pt, this message translates to:
  /// **'Liberar a Escolinha agora'**
  String get parentsUnlockSchool;

  /// No description provided for @parentsGradeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Série da criança'**
  String get parentsGradeLabel;

  /// No description provided for @parentsGradeChangeNote.
  ///
  /// In pt, this message translates to:
  /// **'Trocar a série não apaga o que foi construído; os objetivos do ano recomeçam.'**
  String get parentsGradeChangeNote;

  /// No description provided for @parentsSchoolProgress.
  ///
  /// In pt, this message translates to:
  /// **'{stars} estrelas na escola · {medals} medalhas'**
  String parentsSchoolProgress(int stars, int medals);

  /// No description provided for @shapeCircle.
  ///
  /// In pt, this message translates to:
  /// **'círculo'**
  String get shapeCircle;

  /// No description provided for @shapeSquare.
  ///
  /// In pt, this message translates to:
  /// **'quadrado'**
  String get shapeSquare;

  /// No description provided for @shapeTriangle.
  ///
  /// In pt, this message translates to:
  /// **'triângulo'**
  String get shapeTriangle;

  /// No description provided for @shapeStar.
  ///
  /// In pt, this message translates to:
  /// **'estrela'**
  String get shapeStar;

  /// No description provided for @shapeHeart.
  ///
  /// In pt, this message translates to:
  /// **'coração'**
  String get shapeHeart;

  /// Cor como adjetivo, concordando com o gênero do substantivo ("a estrela vermelha"); idioma sem gênero ignora
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, f{vermelha} other{vermelho}}'**
  String colorRedFor(String gender);

  /// No description provided for @colorBlueFor.
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, other{azul}}'**
  String colorBlueFor(String gender);

  /// No description provided for @colorYellowFor.
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, f{amarela} other{amarelo}}'**
  String colorYellowFor(String gender);

  /// No description provided for @colorGreenFor.
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, other{verde}}'**
  String colorGreenFor(String gender);

  /// No description provided for @colorPurpleFor.
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, f{roxa} other{roxo}}'**
  String colorPurpleFor(String gender);

  /// Ordem forma+cor no idioma (pt: "quadrado azul"; en: "blue square")
  ///
  /// In pt, this message translates to:
  /// **'{shape} {color}'**
  String shapeWithColor(String shape, String color);

  /// No description provided for @shapesDone.
  ///
  /// In pt, this message translates to:
  /// **'Você conhece as formas!'**
  String get shapesDone;

  /// No description provided for @countIntro.
  ///
  /// In pt, this message translates to:
  /// **'Toque nas plantinhas e conte! Quantas são?'**
  String get countIntro;

  /// No description provided for @countRetry.
  ///
  /// In pt, this message translates to:
  /// **'Conte as plantinhas de novo!'**
  String get countRetry;

  /// Números falados de 0 a 10, separados por vírgula (contagem da Horta)
  ///
  /// In pt, this message translates to:
  /// **'zero,um,dois,três,quatro,cinco,seis,sete,oito,nove,dez'**
  String get countNumbers;

  /// No description provided for @countPlant.
  ///
  /// In pt, this message translates to:
  /// **'plantinha'**
  String get countPlant;

  /// No description provided for @countDone.
  ///
  /// In pt, this message translates to:
  /// **'Você contou tudo!'**
  String get countDone;

  /// No description provided for @lettersPrompt.
  ///
  /// In pt, this message translates to:
  /// **'{name}! Com qual letra começa?'**
  String lettersPrompt(String name);

  /// No description provided for @lettersCorrect.
  ///
  /// In pt, this message translates to:
  /// **'{praise} Começa com {letter}!'**
  String lettersCorrect(String praise, String letter);

  /// No description provided for @lettersDone.
  ///
  /// In pt, this message translates to:
  /// **'Você descobriu as letras!'**
  String get lettersDone;

  /// Biblioteca: letras com acento que contam como a letra base na inicial (pares letra=base, separados por vírgula). Cada idioma define a sua — ex.: em espanhol o ñ NÃO entra, porque é uma letra própria. Vazio = nenhuma troca.
  ///
  /// In pt, this message translates to:
  /// **'á=a,à=a,â=a,ã=a,é=e,ê=e,í=i,ó=o,ô=o,õ=o,ú=u,ç=c'**
  String get letterFold;

  /// No description provided for @rhythmWatch.
  ///
  /// In pt, this message translates to:
  /// **'Olhe e escute!'**
  String get rhythmWatch;

  /// No description provided for @rhythmTurn.
  ///
  /// In pt, this message translates to:
  /// **'Sua vez!'**
  String get rhythmTurn;

  /// No description provided for @rhythmRetry.
  ///
  /// In pt, this message translates to:
  /// **'Quase! Vamos ouvir de novo!'**
  String get rhythmRetry;

  /// No description provided for @rhythmNote.
  ///
  /// In pt, this message translates to:
  /// **'Olhe, escute e repita a sequência!'**
  String get rhythmNote;

  /// No description provided for @rhythmPad.
  ///
  /// In pt, this message translates to:
  /// **'Botão {n}'**
  String rhythmPad(int n);

  /// No description provided for @rhythmDone.
  ///
  /// In pt, this message translates to:
  /// **'Que música bonita!'**
  String get rhythmDone;

  /// No description provided for @sortPrompt.
  ///
  /// In pt, this message translates to:
  /// **'{gender, select, f{Onde vai a {name}? Frutas ou legumes?} other{Onde vai o {name}? Frutas ou legumes?}}'**
  String sortPrompt(String gender, String name);

  /// No description provided for @sortRetry.
  ///
  /// In pt, this message translates to:
  /// **'Frutas ou legumes?'**
  String get sortRetry;

  /// No description provided for @sortFruits.
  ///
  /// In pt, this message translates to:
  /// **'Frutas'**
  String get sortFruits;

  /// No description provided for @sortVeggies.
  ///
  /// In pt, this message translates to:
  /// **'Legumes'**
  String get sortVeggies;

  /// No description provided for @sortDone.
  ///
  /// In pt, this message translates to:
  /// **'Tudo separadinho!'**
  String get sortDone;

  /// No description provided for @musicOn.
  ///
  /// In pt, this message translates to:
  /// **'Música ligada'**
  String get musicOn;

  /// No description provided for @musicOff.
  ///
  /// In pt, this message translates to:
  /// **'Música desligada'**
  String get musicOff;

  /// Rótulo do leitor de tela de um espaço construído
  ///
  /// In pt, this message translates to:
  /// **'{name}, nível {level} de {max}'**
  String schoolLotLevel(String name, int level, int max);

  /// No description provided for @schoolLotEmpty.
  ///
  /// In pt, this message translates to:
  /// **'{name}, vazio, construir por {cost} estrelas'**
  String schoolLotEmpty(String name, int cost);

  /// No description provided for @schoolLotLocked.
  ///
  /// In pt, this message translates to:
  /// **'{name}, chega no {grade}'**
  String schoolLotLocked(String name, String grade);

  /// Espaço trancado pela ordem: o anterior ainda não foi concluído (construído + 1 aula)
  ///
  /// In pt, this message translates to:
  /// **'Ainda não! Primeiro: {name}.'**
  String schoolLockedPrev(String name);

  /// Aulas em ordem: só uma aula fica liberada por vez
  ///
  /// In pt, this message translates to:
  /// **'A próxima aula é: {name}!'**
  String schoolNextLesson(String name);

  /// No description provided for @schoolLotSequenceLocked.
  ///
  /// In pt, this message translates to:
  /// **'{name}, trancado'**
  String schoolLotSequenceLocked(String name);

  /// No description provided for @missionLocked.
  ///
  /// In pt, this message translates to:
  /// **'Trancado — resgate o objetivo anterior primeiro'**
  String get missionLocked;

  /// No description provided for @homeTrail.
  ///
  /// In pt, this message translates to:
  /// **'Trilha'**
  String get homeTrail;

  /// No description provided for @homeTrailProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total}'**
  String homeTrailProgress(int done, int total);

  /// No description provided for @homeSchoolLocked.
  ///
  /// In pt, this message translates to:
  /// **'A Escolinha abre quando você terminar a trilha!'**
  String get homeSchoolLocked;

  /// No description provided for @trailHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque na estrela brilhante!'**
  String get trailHint;

  /// Rótulo (leitor de tela) do botão 🏠 que volta ao menu inicial
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get homeButton;

  /// No description provided for @parentsExitLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sair do app'**
  String get parentsExitLabel;

  /// No description provided for @parentsExitHint.
  ///
  /// In pt, this message translates to:
  /// **'Fecha o Genius Kiddo. O progresso fica salvo neste aparelho.'**
  String get parentsExitHint;

  /// Rótulo (leitor de tela) do botão 🎯 e da seta de borda que levam a câmera ao espaço brilhante
  ///
  /// In pt, this message translates to:
  /// **'Ir ao espaço brilhante'**
  String get worldGoToGlow;

  /// Fala da 1ª vez no mapa, junto com a mãozinha animada (RM-02)
  ///
  /// In pt, this message translates to:
  /// **'Arraste o dedo para ver a escola!'**
  String get worldDragHint;

  /// Fala ao tocar num aluno que passeia no mapa (RM-07)
  ///
  /// In pt, this message translates to:
  /// **'Oi! Eu estudo aqui!'**
  String get worldKidHello;

  /// No description provided for @worldKidLabel.
  ///
  /// In pt, this message translates to:
  /// **'Aluno'**
  String get worldKidLabel;

  /// Rótulo (leitor de tela) do botão 🔊 que repete a fala do guia
  ///
  /// In pt, this message translates to:
  /// **'Ouvir de novo'**
  String get repeatButton;

  /// Fala ao abrir um espaço da escola: nome + descrição
  ///
  /// In pt, this message translates to:
  /// **'{name}! {desc}'**
  String spaceIntro(String name, String desc);

  /// No description provided for @parentsVoiceOnLabel.
  ///
  /// In pt, this message translates to:
  /// **'Voz do guia ligada'**
  String get parentsVoiceOnLabel;

  /// RF-FASE-03 / 4.7: atalho de progresso dos pais
  ///
  /// In pt, this message translates to:
  /// **'Liberar todas as etapas da trilha'**
  String get parentsUnlockTrail;

  /// No description provided for @parentsUnlockTrailHint.
  ///
  /// In pt, this message translates to:
  /// **'Libera as etapas sem dar estrelas; a criança pode jogar em qualquer ordem.'**
  String get parentsUnlockTrailHint;

  /// Botão do topo que abre o Controle dos pais (segurar 2 s)
  ///
  /// In pt, this message translates to:
  /// **'Pais'**
  String get parentsEntry;

  /// No description provided for @parentsHoldHint.
  ///
  /// In pt, this message translates to:
  /// **'Segure para abrir'**
  String get parentsHoldHint;

  /// No description provided for @parentsCardVoice.
  ///
  /// In pt, this message translates to:
  /// **'Idioma e voz'**
  String get parentsCardVoice;

  /// No description provided for @parentsCardHelp.
  ///
  /// In pt, this message translates to:
  /// **'Como usar'**
  String get parentsCardHelp;

  /// No description provided for @parentsSummaryTrail.
  ///
  /// In pt, this message translates to:
  /// **'Trilha {done}/{total}'**
  String parentsSummaryTrail(int done, int total);

  /// No description provided for @parentsSummaryBreak.
  ///
  /// In pt, this message translates to:
  /// **'Pausa {minutes} min'**
  String parentsSummaryBreak(int minutes);

  /// No description provided for @parentsSummaryBreakOff.
  ///
  /// In pt, this message translates to:
  /// **'Pausa desligada'**
  String get parentsSummaryBreakOff;

  /// No description provided for @parentsSummaryVoiceOff.
  ///
  /// In pt, this message translates to:
  /// **'Voz desligada'**
  String get parentsSummaryVoiceOff;

  /// Tela "Como usar" do Controle dos pais (guia para o adulto)
  ///
  /// In pt, this message translates to:
  /// **'O Genius Kiddo é para crianças de 3 a 5 anos, de preferência com um adulto por perto. Tudo funciona sem internet e nada sai do aparelho.'**
  String get helpIntro;

  /// No description provided for @helpMenuTitle.
  ///
  /// In pt, this message translates to:
  /// **'Menu inicial'**
  String get helpMenuTitle;

  /// No description provided for @helpMenuBody.
  ///
  /// In pt, this message translates to:
  /// **'É a primeira tela depois da abertura. Tem três cartões grandes: Trilha, Escolinha e Rabisco livre. Os botões de bandeira trocam o idioma, a nota liga ou desliga a música e a lua troca a aparência.'**
  String get helpMenuBody;

  /// No description provided for @helpTrailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trilha'**
  String get helpTrailTitle;

  /// No description provided for @helpTrailBody.
  ///
  /// In pt, this message translates to:
  /// **'São 8 atividades em ordem (pintar, ouvir, sombra, traçar, falar). A próxima só abre quando a anterior termina, e a etapa atual pulsa com a mãozinha 👆. Cada etapa concluída pela primeira vez dá 1 estrela. Não há erro que tire estrela: a criança pode tentar quantas vezes quiser.'**
  String get helpTrailBody;

  /// No description provided for @helpSchoolTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolinha'**
  String get helpSchoolTitle;

  /// No description provided for @helpSchoolBody.
  ///
  /// In pt, this message translates to:
  /// **'Abre quando a trilha termina (ou antes, se você liberar aqui). Na primeira entrada, você escolhe a série da criança segurando o cadeado. Cada aula dá 3 estrelas, e as estrelas constroem e melhoram os espaços. Os espaços abrem um de cada vez, e só uma aula fica liberada por vez: o Kiddo sempre diz qual é a próxima.'**
  String get helpSchoolBody;

  /// No description provided for @helpMapTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mapa da escola'**
  String get helpMapTitle;

  /// No description provided for @helpMapBody.
  ///
  /// In pt, this message translates to:
  /// **'A escola é um mapa maior que a tela: arraste o dedo em qualquer direção. Se a criança se perder, a seta amarela na borda ou o botão 🎯 levam até o espaço que está brilhando. As nuvens cobrem as áreas das próximas séries e se abrem ao passar de ano.'**
  String get helpMapBody;

  /// No description provided for @helpGuideTitle.
  ///
  /// In pt, this message translates to:
  /// **'O Kiddo e o 🔊'**
  String get helpGuideTitle;

  /// No description provided for @helpGuideBody.
  ///
  /// In pt, this message translates to:
  /// **'O Kiddo fala cada instrução e mostra o mesmo texto no balão, para você acompanhar. O botão 🔊 repete a última fala. Tocar numa figura faz o Kiddo dizer o nome dela.'**
  String get helpGuideBody;

  /// No description provided for @helpParentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle dos pais'**
  String get helpParentsTitle;

  /// No description provided for @helpParentsBody.
  ///
  /// In pt, this message translates to:
  /// **'Fica no botão 🔒 Pais, no alto de cada tela: segure por 2 segundos para abrir. A criança pequena não consegue, então não muda nada sem querer. Aqui você ajusta idioma, voz, pausa, série, aparência e pode sair do app.'**
  String get helpParentsBody;

  /// No description provided for @helpBreakTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pausa para descansar'**
  String get helpBreakTitle;

  /// No description provided for @helpBreakBody.
  ///
  /// In pt, this message translates to:
  /// **'Depois do tempo escolhido de uso contínuo (15 minutos, se você não mudar), aparece a pausa \"Hora de descansar os olhinhos\". Só um adulto fecha, segurando o cadeado dela.'**
  String get helpBreakBody;

  /// No description provided for @helpStuckTitle.
  ///
  /// In pt, this message translates to:
  /// **'Se a criança ficar travada'**
  String get helpStuckTitle;

  /// No description provided for @helpStuckBody.
  ///
  /// In pt, this message translates to:
  /// **'Toque no 🔊 para ouvir de novo. Nas atividades, depois de um toque fora, a resposta certa ganha um contorno amarelo. Item trancado treme e o Kiddo explica o que vem antes. O botão 🏠 sempre volta para o menu.'**
  String get helpStuckBody;

  /// No description provided for @parentsPrivacyFullPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política completa:'**
  String get parentsPrivacyFullPolicy;

  /// No description provided for @parentsPrivacyCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar endereço'**
  String get parentsPrivacyCopy;

  /// No description provided for @parentsPrivacyCopied.
  ///
  /// In pt, this message translates to:
  /// **'Endereço copiado'**
  String get parentsPrivacyCopied;

  /// No description provided for @parentsPrivacyContact.
  ///
  /// In pt, this message translates to:
  /// **'Contato:'**
  String get parentsPrivacyContact;

  /// Dica no botão quadrado "🔒 Pais" após um toque rápido
  ///
  /// In pt, this message translates to:
  /// **'Segure 2 s'**
  String get parentsHoldHintShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
