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
  String get itemFlower => 'flower';

  @override
  String get itemMoon => 'moon';

  @override
  String get itemHouse => 'house';

  @override
  String get itemGrape => 'grape';

  @override
  String get itemFrog => 'frog';

  @override
  String get itemDuck => 'duck';

  @override
  String get itemCow => 'cow';

  @override
  String get itemLion => 'lion';

  @override
  String get itemEgg => 'egg';

  @override
  String get itemBee => 'bee';

  @override
  String get itemBear => 'bear';

  @override
  String get itemStrawberry => 'strawberry';

  @override
  String get itemOrange => 'orange';

  @override
  String get itemWatermelon => 'watermelon';

  @override
  String get itemCarrot => 'carrot';

  @override
  String get itemBroccoli => 'broccoli';

  @override
  String get itemPotato => 'potato';

  @override
  String get itemLettuce => 'lettuce';

  @override
  String get itemOnion => 'onion';

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
  String listenPrompt(String gender, String name) {
    return 'Tap the $name!';
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
  String get freeDrawFirst => 'Draw a little first!';

  @override
  String get freeDrawCelebrate => 'What a lovely drawing!';

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

  @override
  String get breakMessage =>
      'Time to rest your eyes! Shall we drink some water?';

  @override
  String get breakHoldHint => 'Ask a grown-up to hold here';

  @override
  String get parentGateLabel => 'Parental controls';

  @override
  String get parentsAreaTitle => 'Parental controls';

  @override
  String get parentsLanguageLabel => 'Language';

  @override
  String get parentsSoundLabel => 'Sound and voice';

  @override
  String get parentsMusicLabel => 'Music';

  @override
  String get parentsVoiceToneLabel => 'Voice tone';

  @override
  String get parentsVoiceToneSuave => 'Gentle';

  @override
  String get parentsVoiceToneFofa => 'Sweet';

  @override
  String get parentsVoiceToneSuper => 'Extra sweet';

  @override
  String get parentsVoicePickLabel => 'Guide\'s voice';

  @override
  String get parentsVoiceAuto => 'Automatic';

  @override
  String get parentsTestVoice => 'Test the voice';

  @override
  String get parentsVoiceTestPhrase => 'Hi! This is my voice!';

  @override
  String get parentsBreakLabel => 'Suggested break';

  @override
  String get parentsBreakOff => 'Off';

  @override
  String parentsBreakMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get parentsProgressLabel => 'Progress';

  @override
  String parentsProgressSteps(int done, int total) {
    return '$done of $total steps completed';
  }

  @override
  String parentsProgressStars(int stars) {
    return '$stars stars';
  }

  @override
  String get parentsAppearanceLabel => 'Appearance';

  @override
  String get parentsThemeAuto => 'Automatic';

  @override
  String get parentsThemeLight => 'Light';

  @override
  String get parentsThemeDark => 'Dark';

  @override
  String get parentsPrivacyLabel => 'Privacy';

  @override
  String get parentsPrivacySummary =>
      'Genius Kiddo never asks for the child\'s name, birth date or email. Everything is stored only on this device, with no internet connection, and the child\'s voice is never recorded.';

  @override
  String get trailSchool => 'School';

  @override
  String get gradeGateTitle => 'For parents';

  @override
  String get gradeGateHint => 'Hold the lock to choose the child\'s grade.';

  @override
  String get gradeChoiceTitle => 'Which grade?';

  @override
  String get gradeChoiceSubtitle =>
      'Choose the child\'s grade. You can change it later in the parents area.';

  @override
  String get gradeName0 => 'Nursery';

  @override
  String get gradeName1 => 'Pre-K 1';

  @override
  String get gradeName2 => 'Pre-K 2';

  @override
  String gradeAge(int age) {
    return '$age years old';
  }

  @override
  String get spaceName_sala => 'Classroom';

  @override
  String get spaceDesc_sala => 'Here we learn shapes and colors!';

  @override
  String get spaceName_horta => 'Garden';

  @override
  String get spaceDesc_horta => 'Here we count the plants!';

  @override
  String get spaceName_atelie => 'Art studio';

  @override
  String get spaceDesc_atelie => 'Here we paint beautiful pictures!';

  @override
  String get spaceName_biblio => 'Library';

  @override
  String get spaceDesc_biblio => 'Here we discover letters!';

  @override
  String get spaceName_patio => 'Playground';

  @override
  String get spaceDesc_patio => 'Here we play repeat the sounds!';

  @override
  String get spaceName_refeit => 'Lunchroom';

  @override
  String get spaceDesc_refeit => 'Here we sort fruits and veggies!';

  @override
  String get schoolWelcomeFirst => 'Welcome to our school! Tap the classroom!';

  @override
  String get schoolWelcomeBack =>
      'Hi! So good to see you! Shall we take care of our school?';

  @override
  String get schoolHintGoal => 'You reached a goal! Tap the trophy!';

  @override
  String get schoolHintStars => 'You have stars! Tap the glowing space!';

  @override
  String get schoolHintLesson => 'Tap a space to have a lesson and earn stars!';

  @override
  String schoolGradeLocked(String grade) {
    return 'This space arrives in $grade! Let us move up a grade!';
  }

  @override
  String get schoolBuild => 'Build';

  @override
  String get schoolUpgrade => 'Upgrade';

  @override
  String get schoolLesson => 'Start lesson';

  @override
  String get schoolEarnStars => 'Earn stars';

  @override
  String get schoolMaxed => 'Fully grown! 🌟';

  @override
  String get schoolClose => 'Close';

  @override
  String get schoolBuilt => 'So pretty! Our school grew!';

  @override
  String get schoolUpgraded => 'Wow! It got even better!';

  @override
  String get schoolNeedStars => 'Do a lesson to earn stars!';

  @override
  String get goalsButton => 'Goals';

  @override
  String goalsTitle(String grade) {
    return 'Goals for $grade';
  }

  @override
  String missionBuild(int n) {
    return 'Build $n spaces';
  }

  @override
  String missionLessons(int n) {
    return 'Do $n lessons';
  }

  @override
  String missionUpgrade(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Upgrade $n spaces',
      one: 'Upgrade a space',
    );
    return '$_temp0';
  }

  @override
  String missionMax(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Max out $n spaces',
      one: 'Max out a space',
    );
    return '$_temp0';
  }

  @override
  String get goalClaim => 'Get';

  @override
  String get medalEarned => 'Medal earned! Congratulations!';

  @override
  String get promoteButton => 'Next grade';

  @override
  String get graduateButton => 'Graduate';

  @override
  String get graduatedBadge => 'Graduated!';

  @override
  String promoted(String grade) {
    return 'Congratulations! You are now in $grade! New spaces arrived!';
  }

  @override
  String get graduated =>
      'Graduation! You finished the school! Coming soon: 1st grade!';

  @override
  String get afterPromotion => 'Tap the new glowing space!';

  @override
  String get afterGraduation => 'Shall we play more in our school?';

  @override
  String get graduationDoneNote =>
      '🎓 Graduation complete! Coming soon: 1st grade.';

  @override
  String get parentsSchoolLabel => 'School';

  @override
  String get parentsSchoolLockedHint =>
      'The School opens when the child finishes the trail steps.';

  @override
  String get parentsUnlockSchool => 'Unlock the School now';

  @override
  String get parentsGradeLabel => 'Child\'s grade';

  @override
  String get parentsGradeChangeNote =>
      'Changing the grade keeps everything built; the year\'s goals start over.';

  @override
  String parentsSchoolProgress(int stars, int medals) {
    return '$stars stars at school · $medals medals';
  }

  @override
  String get shapeCircle => 'circle';

  @override
  String get shapeSquare => 'square';

  @override
  String get shapeTriangle => 'triangle';

  @override
  String get shapeStar => 'star';

  @override
  String get shapeHeart => 'heart';

  @override
  String colorRedFor(String gender) {
    return 'red';
  }

  @override
  String colorBlueFor(String gender) {
    return 'blue';
  }

  @override
  String colorYellowFor(String gender) {
    return 'yellow';
  }

  @override
  String colorGreenFor(String gender) {
    return 'green';
  }

  @override
  String colorPurpleFor(String gender) {
    return 'purple';
  }

  @override
  String shapeWithColor(String shape, String color) {
    return '$color $shape';
  }

  @override
  String get shapesDone => 'You know your shapes!';

  @override
  String get countIntro => 'Tap the plants and count! How many are there?';

  @override
  String get countRetry => 'Count the plants again!';

  @override
  String get countNumbers =>
      'zero,one,two,three,four,five,six,seven,eight,nine,ten';

  @override
  String get countPlant => 'plant';

  @override
  String get countDone => 'You counted them all!';

  @override
  String lettersPrompt(String name) {
    return '$name! Which letter does it start with?';
  }

  @override
  String lettersCorrect(String praise, String letter) {
    return '$praise It starts with $letter!';
  }

  @override
  String get lettersDone => 'You found the letters!';

  @override
  String get letterFold => '';

  @override
  String get rhythmWatch => 'Watch and listen!';

  @override
  String get rhythmTurn => 'Your turn!';

  @override
  String get rhythmRetry => 'Almost! Let us listen again!';

  @override
  String get rhythmNote => 'Watch, listen and repeat the sequence!';

  @override
  String rhythmPad(int n) {
    return 'Pad $n';
  }

  @override
  String get rhythmDone => 'What lovely music!';

  @override
  String sortPrompt(String gender, String name) {
    return 'Where does the $name go? Fruits or veggies?';
  }

  @override
  String get sortRetry => 'Fruits or veggies?';

  @override
  String get sortFruits => 'Fruits';

  @override
  String get sortVeggies => 'Veggies';

  @override
  String get sortDone => 'All sorted!';

  @override
  String get musicOn => 'Music on';

  @override
  String get musicOff => 'Music off';

  @override
  String schoolLotLevel(String name, int level, int max) {
    return '$name, level $level of $max';
  }

  @override
  String schoolLotEmpty(String name, int cost) {
    return '$name, empty, build for $cost stars';
  }

  @override
  String schoolLotLocked(String name, String grade) {
    return '$name, arrives in $grade';
  }

  @override
  String schoolLockedPrev(String name) {
    return 'Not yet! First: $name.';
  }

  @override
  String schoolNextLesson(String name) {
    return 'The next lesson is: $name!';
  }

  @override
  String schoolLotSequenceLocked(String name) {
    return '$name, locked';
  }

  @override
  String get missionLocked => 'Locked — claim the previous goal first';

  @override
  String get homeTrail => 'Trail';

  @override
  String homeTrailProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get homeSchoolLocked => 'The School opens when you finish the trail!';

  @override
  String get trailHint => 'Tap the glowing star!';

  @override
  String get homeButton => 'Home';

  @override
  String get parentsExitLabel => 'Exit the app';

  @override
  String get parentsExitHint =>
      'Closes Genius Kiddo. Progress stays saved on this device.';

  @override
  String get worldGoToGlow => 'Go to the glowing space';

  @override
  String get worldDragHint => 'Drag your finger to see the school!';

  @override
  String get worldKidHello => 'Hi! I study here!';

  @override
  String get worldKidLabel => 'Student';

  @override
  String get repeatButton => 'Hear it again';

  @override
  String spaceIntro(String name, String desc) {
    return '$name! $desc';
  }

  @override
  String get parentsVoiceOnLabel => 'Guide voice on';

  @override
  String get parentsUnlockTrail => 'Unlock all trail steps';

  @override
  String get parentsUnlockTrailHint =>
      'Unlocks the steps without giving stars; the child can play in any order.';

  @override
  String get parentsEntry => 'Parents';

  @override
  String get parentsHoldHint => 'Hold to open';

  @override
  String get parentsCardVoice => 'Language and voice';

  @override
  String get parentsCardHelp => 'How to use';

  @override
  String parentsSummaryTrail(int done, int total) {
    return 'Trail $done/$total';
  }

  @override
  String parentsSummaryBreak(int minutes) {
    return 'Break $minutes min';
  }

  @override
  String get parentsSummaryBreakOff => 'Break off';

  @override
  String get parentsSummaryVoiceOff => 'Voice off';

  @override
  String get helpIntro =>
      'Genius Kiddo is for children aged 3 to 5, ideally with an adult nearby. Everything works offline and nothing leaves the device.';

  @override
  String get helpMenuTitle => 'Home menu';

  @override
  String get helpMenuBody =>
      'It is the first screen after the opening. It has three big cards: Trail, School and Free draw. The flag buttons change the language, the note turns music on or off and the moon changes the appearance.';

  @override
  String get helpTrailTitle => 'Trail';

  @override
  String get helpTrailBody =>
      'There are 8 activities in order (paint, listen, shadow, trace, speak). The next one opens only when the previous one is done, and the current step pulses with the little hand 👆. Each step finished for the first time gives 1 star. No mistake takes a star away: the child can try as many times as they like.';

  @override
  String get helpSchoolTitle => 'School';

  @override
  String get helpSchoolBody =>
      'It opens when the trail is finished (or earlier, if you unlock it here). On the first visit, you choose the child\'s grade by holding the lock. Each lesson gives 3 stars, and stars build and upgrade the spaces. Spaces open one at a time, and only one lesson is open at a time: Kiddo always says which one is next.';

  @override
  String get helpMapTitle => 'School map';

  @override
  String get helpMapBody =>
      'The school is a map bigger than the screen: drag your finger in any direction. If the child gets lost, the yellow arrow on the edge or the 🎯 button takes you to the glowing space. Clouds cover the areas of the next grades and open when moving up a grade.';

  @override
  String get helpGuideTitle => 'Kiddo and 🔊';

  @override
  String get helpGuideBody =>
      'Kiddo says every instruction and shows the same text in the bubble, so you can follow along. The 🔊 button repeats the last line. Tapping a picture makes Kiddo say its name.';

  @override
  String get helpParentsTitle => 'Parental controls';

  @override
  String get helpParentsBody =>
      'It is the 🔒 Parents button at the top of each screen: hold it for 2 seconds to open. A small child can\'t do it, so nothing changes by accident. Here you set language, voice, break, grade and appearance, and you can exit the app.';

  @override
  String get helpBreakTitle => 'Rest break';

  @override
  String get helpBreakBody =>
      'After the chosen time of continuous use (15 minutes unless you change it), the \"Time to rest your eyes\" break appears. Only an adult can close it, by holding its lock.';

  @override
  String get helpStuckTitle => 'If the child gets stuck';

  @override
  String get helpStuckBody =>
      'Tap 🔊 to hear it again. In activities, after a wrong tap, the right answer gets a yellow outline. A locked item shakes and Kiddo explains what comes first. The 🏠 button always goes back to the menu.';

  @override
  String get parentsPrivacyFullPolicy => 'Full policy:';

  @override
  String get parentsPrivacyCopy => 'Copy address';

  @override
  String get parentsPrivacyCopied => 'Address copied';

  @override
  String get parentsPrivacyContact => 'Contact:';
}
