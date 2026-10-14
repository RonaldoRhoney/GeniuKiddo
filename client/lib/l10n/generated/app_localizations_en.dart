// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Genius Kiddo';

  @override
  String get appTagline => 'learn by playing';

  @override
  String get tapToStart => 'Tap to start';

  @override
  String get languageCardPtLabel => 'Português';

  @override
  String get languageCardEnLabel => 'English';

  @override
  String get welcomeFirst => 'Hi! I am Kiddo!';

  @override
  String get welcomeBack => 'Hi! So good to see you!';

  @override
  String get homePlaceholder =>
      'The activity trail arrives in the next milestone (M2).';
}
