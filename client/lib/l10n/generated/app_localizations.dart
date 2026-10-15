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

  /// Rótulo pequeno do cartão de idioma português (seção 4.5: sem bandeiras)
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languageCardPtLabel;

  /// Rótulo pequeno do cartão de idioma inglês
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageCardEnLabel;

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

  /// No description provided for @listenPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Toque n{article} {name}!'**
  String listenPrompt(String article, String name);

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

  /// Botão grande pra sair do rabisco livre quando a criança terminou (nunca conta como etapa concluída)
  ///
  /// In pt, this message translates to:
  /// **'Pronto!'**
  String get freeDrawDone;

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
