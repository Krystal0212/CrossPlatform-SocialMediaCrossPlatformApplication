import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> initializeFirebaseAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
}
