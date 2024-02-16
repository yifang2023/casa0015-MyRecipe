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
    apiKey: 'AIzaSyD2IqVFKCPHxCLaEi0iq4rCHnoLyNwWs7Y',
    appId: '1:666564843841:web:eed5d130a26222b7f629c0',
    messagingSenderId: '666564843841',
    projectId: 'babyguardian-62662',
    authDomain: 'babyguardian-62662.firebaseapp.com',
    storageBucket: 'babyguardian-62662.appspot.com',
    measurementId: 'G-2VQXFCKZV2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDP7nhlT4KYXxu3Yr6YeDc8bbP_KjOlw1c',
    appId: '1:666564843841:android:0c542563184b0d30f629c0',
    messagingSenderId: '666564843841',
    projectId: 'babyguardian-62662',
    storageBucket: 'babyguardian-62662.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbNLzlHDqu3qwMvpuitIjOHFKjkBm_UnQ',
    appId: '1:666564843841:ios:a39673f52a7827d0f629c0',
    messagingSenderId: '666564843841',
    projectId: 'babyguardian-62662',
    storageBucket: 'babyguardian-62662.appspot.com',
    iosBundleId: 'com.example.babyguardianApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDbNLzlHDqu3qwMvpuitIjOHFKjkBm_UnQ',
    appId: '1:666564843841:ios:a39673f52a7827d0f629c0',
    messagingSenderId: '666564843841',
    projectId: 'babyguardian-62662',
    storageBucket: 'babyguardian-62662.appspot.com',
    iosBundleId: 'com.example.babyguardianApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD2IqVFKCPHxCLaEi0iq4rCHnoLyNwWs7Y',
    appId: '1:666564843841:web:c6dc6ee873540cfef629c0',
    messagingSenderId: '666564843841',
    projectId: 'babyguardian-62662',
    authDomain: 'babyguardian-62662.firebaseapp.com',
    storageBucket: 'babyguardian-62662.appspot.com',
    measurementId: 'G-PC31SKCXSF',
  );
}
