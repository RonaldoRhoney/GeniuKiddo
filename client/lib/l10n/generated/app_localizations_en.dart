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
  String get itemDog => 'dog';

  @override
  String get itemCat => 'cat';

  @override
  String get itemFish => 'fish';

  @override
  String get itemBird => 'bird';

  @override
  String get itemApple => 'apple';

  @override
  String get itemBanana => 'banana';

  @override
  String get itemCar => 'car';

  @override
  String get itemBall => 'ball';

  @override
  String get itemSun => 'sun';

  @override
  String get colorRed => 'red';

  @override
  String get colorBlue => 'blue';

  @override
  String get colorYellow => 'yellow';

  @override
  String get colorGreen => 'green';

  @override
  String get colorPurple => 'purple';

  @override
  String get colorOrange => 'orange';

  @override
  String get trailNodePaintGarden => 'Paint the garden';

  @override
  String get trailNodeListenAnimals => 'Listen: animals';

  @override
  String get trailNodeMatchShadow => 'Who is the shadow?';

  @override
  String get trailNodeTrace1 => 'Trace the number 1';

  @override
  String get trailNodeSpeakWords => 'Repeat words';

  @override
  String get trailNodePaintHouse => 'Paint the house';

  @override
  String get trailNodeListenFruits => 'Listen: fruits & things';

  @override
  String get trailNodeTraceO => 'Trace the letter O';

  @override
  String get trailLocked => 'Not yet! Let us do the glowing star first!';

  @override
  String get trailFreeDraw => 'Free draw';

  @override
  String get trailNewActivity => 'A new activity appeared! Tap the star!';

  @override
  String get trailAllDone => 'You finished the trail! Want to play again?';

  @override
  String get trailPlayMore => 'Want to play more?';

  @override
  String get paintIntro => 'Pick a color and tap the picture!';

  @override
  String get paintDone => 'So pretty! You painted it all!';

  @override
  String traceIntro(String glyphName) {
    return 'Follow the path and draw $glyphName!';
  }

  @override
  String traceDone(String glyphName) {
    return 'Great! You drew $glyphName!';
  }

  @override
  String get glyphName1 => 'the number 1';

  @override
  String get glyphNameO => 'the letter O';

  @override
  String listenPrompt(String article, String name) {
    return 'Tap $article $name!';
  }

  @override
  String get listenDone => 'You listened and got them all!';

  @override
  String get matchIntro => 'Who is hiding in the shadow?';

  @override
  String get matchDone => 'You found all the shadows!';

  @override
  String speakPrompt(String name) {
    return 'Say: $name! Now it is your turn!';
  }

  @override
  String get speakDone => 'You repeated all the words!';

  @override
  String get speakMicNote => 'The app never records the child\'s voice';

  @override
  String get speakGood => 'Very good! You said it great!';

  @override
  String get speakISaidIt => 'I said it';

  @override
  String get freeDrawIntro => 'Draw your own way!';

  @override
  String get freeDrawClear => 'clear';

  @override
  String get freeDrawDone => 'Done!';

  @override
  String get praise1 => 'Great job!';

  @override
  String get praise2 => 'Yes! That is right!';

  @override
  String get praise3 => 'Wow, well done!';

  @override
  String get praise4 => 'Awesome!';

  @override
  String get celebrationContinue => 'Continue';
}
