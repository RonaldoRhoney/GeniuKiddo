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
  String get homePlaceholder =>
      'A trilha de atividades chega no próximo marco (M2).';
}
