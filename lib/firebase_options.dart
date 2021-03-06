// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDYH1WBQXUgrQL3BaOBOiiFKdxLwR7cg10',
    appId: '1:701446495044:web:13791c0c19156b19879511',
    messagingSenderId: '701446495044',
    projectId: 'parry-b18e0',
    authDomain: 'parry-b18e0.firebaseapp.com',
    storageBucket: 'parry-b18e0.appspot.com',
    measurementId: 'G-3K9FD7KMSR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA31tUNuGpYF9hEBaRzwQRJi9tKQIVwexI',
    appId: '1:701446495044:android:f7d464a1564d87b7879511',
    messagingSenderId: '701446495044',
    projectId: 'parry-b18e0',
    storageBucket: 'parry-b18e0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2UBvU9ii23-ZPSUwW4QHr2kosYr5ekp0',
    appId: '1:701446495044:ios:3d7184e8c5c5e3ae879511',
    messagingSenderId: '701446495044',
    projectId: 'parry-b18e0',
    storageBucket: 'parry-b18e0.appspot.com',
    androidClientId: '701446495044-15007c6uq6tsbtllmdhri9l5prhrhjgd.apps.googleusercontent.com',
    iosClientId: '701446495044-j0sae489phucrapjndh6a42tr7na6anf.apps.googleusercontent.com',
    iosBundleId: 'com.arma7x.flutterLaravel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2UBvU9ii23-ZPSUwW4QHr2kosYr5ekp0',
    appId: '1:701446495044:ios:3d7184e8c5c5e3ae879511',
    messagingSenderId: '701446495044',
    projectId: 'parry-b18e0',
    storageBucket: 'parry-b18e0.appspot.com',
    androidClientId: '701446495044-15007c6uq6tsbtllmdhri9l5prhrhjgd.apps.googleusercontent.com',
    iosClientId: '701446495044-j0sae489phucrapjndh6a42tr7na6anf.apps.googleusercontent.com',
    iosBundleId: 'com.arma7x.flutterLaravel',
  );
}
