// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_8oN3udEAtJjzySdEI_fzgahCa0E71O0',
    appId: '1:114934148574:web:1fc7c8d7259e104589414f',
    messagingSenderId: '114934148574',
    projectId: 'nihaar-88365',
    authDomain: 'nihaar-88365.firebaseapp.com',
    storageBucket: 'nihaar-88365.appspot.com',
    measurementId: 'G-KWFYLW3X28',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRbt5zBypc3JnM_wWa-rc4RAvEEaZNZAI',
    appId: '1:114934148574:android:c8734f67ecc5f5fd89414f',
    messagingSenderId: '114934148574',
    projectId: 'nihaar-88365',
    storageBucket: 'nihaar-88365.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQz4A7GouckX30ZuWfgFu8SwRmIkHHq2I',
    appId: '1:114934148574:ios:42cb39b2ee663ea889414f',
    messagingSenderId: '114934148574',
    projectId: 'nihaar-88365',
    storageBucket: 'nihaar-88365.appspot.com',
    iosBundleId: 'com.example.nihaar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAQz4A7GouckX30ZuWfgFu8SwRmIkHHq2I',
    appId: '1:114934148574:ios:42cb39b2ee663ea889414f',
    messagingSenderId: '114934148574',
    projectId: 'nihaar-88365',
    storageBucket: 'nihaar-88365.appspot.com',
    iosBundleId: 'com.example.nihaar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB_8oN3udEAtJjzySdEI_fzgahCa0E71O0',
    appId: '1:114934148574:web:328f34c3e48cd23189414f',
    messagingSenderId: '114934148574',
    projectId: 'nihaar-88365',
    authDomain: 'nihaar-88365.firebaseapp.com',
    storageBucket: 'nihaar-88365.appspot.com',
    measurementId: 'G-SMSVG2WSL1',
  );
}