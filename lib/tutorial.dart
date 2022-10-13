import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// The keys for the elements, so that they can be referenced later in the tutorial.
GlobalKey floatingActionButtonKey = GlobalKey();
GlobalKey settingsButton = GlobalKey();
GlobalKey saveButton = GlobalKey();
GlobalKey offlineModeSwitch = GlobalKey();
GlobalKey railColourPicker = GlobalKey();
GlobalKey railTolerancePicker = GlobalKey();
GlobalKey frequencyPicker = GlobalKey();
GlobalKey phoneSettingsButton = GlobalKey();

// Das Tutorial, damit wir es später manuell anzeigen können
TutorialCoachMark? tutorialCoachMark;

// The different points for the tutorial
List<TargetFocus> targets = [
  TargetFocus(
    identify: "floatingActionButton",
    keyTarget: floatingActionButtonKey,
    alignSkip: Alignment.topRight,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        child: const Text(
          "While you are online, you can see whether you are near enough to a railway for the app to record a journey.",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "settingsButton",
    alignSkip: Alignment.bottomRight,
    keyTarget: settingsButton,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          'Tap here to open settings: Here you can control different aspects of the app. ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "offlineModeSwitch",
    alignSkip: Alignment.bottomRight,
    keyTarget: offlineModeSwitch,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          'Tap here to enable offlineMode. This will disable checking for railways near you online and allows use of the app without an active internet connection.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "floatingActionButton2",
    alignSkip: Alignment.bottomLeft,
    keyTarget: floatingActionButtonKey,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        child: const Text(
          "While in offline mode you can manually choose, whether or not the app should draw a line.",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "railColourPicker",
    alignSkip: Alignment.bottomLeft,
    keyTarget: railColourPicker,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        child: const Text(
          "Here you can change the default color of the railway lines.",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "railTolerancePicker",
    alignSkip: Alignment.bottomLeft,
    keyTarget: railTolerancePicker,
    contents: [
      TargetContent(
        align: ContentAlign.custom,
        customPosition: CustomTargetContentPosition(
          top: 500,
        ),
        child: const Text(
          "Here you can change the default tolerance of the railway lines. This changes how many meters have to be between you and a railway for the app to draw a line.",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "saveFrequency",
    alignSkip: Alignment.bottomLeft,
    keyTarget: frequencyPicker,
    contents: [
      TargetContent(
        align: ContentAlign.custom,
        customPosition: CustomTargetContentPosition(
          top: 520,
        ),
        child: const Text(
          "Here you can change the default frequency of saving your location. This changes how many seconds are between disk saves, whcih can improve performance and battery life.",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "phoneSettingsButton",
    alignSkip: Alignment.bottomLeft,
    keyTarget: phoneSettingsButton,
    contents: [
      TargetContent(
        align: ContentAlign.custom,
        customPosition: CustomTargetContentPosition(
          top: 520,
        ),
        child: const Text(
          "This  button takes you directly to the phone settings for the app. Be sure, that location access is always permitted and all battery optimizations are turned off, as this will cause the app to be terminated.",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  TargetFocus(
    identify: "homeScreen",
    alignSkip: Alignment.bottomLeft,
    targetPosition: TargetPosition(
      const Size(300, 800),
      const Offset(150, 400),
    ),
    radius: 50,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        child: const Text(
          "Remember that you can click on any drawn railway journey, to change it's name, description, date, color or delete it. Have fun!",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
];
