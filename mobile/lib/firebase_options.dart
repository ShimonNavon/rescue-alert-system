import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

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
          'DefaultFirebaseOptions have not been configured for linux - run FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDKVqBWCnBqz2xmebtiD-6VOEHkT4z_zMc',
    appId: '1:631985219642:web:92e47bd81872c938986d03',
    messagingSenderId: '631985219642',
    projectId: 'rescue-alert-prod-12345',
    authDomain: 'rescue-alert-prod-12345.firebaseapp.com',
    storageBucket: 'rescue-alert-prod-12345.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqljhNiUbVG_H22o-BnbNRIvxTCLitE-s',
    appId: '1:631985219642:android:52253edb97222a6f986d03',
    messagingSenderId: '631985219642',
    projectId: 'rescue-alert-prod-12345',
    storageBucket: 'rescue-alert-prod-12345.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKl7I7GegtmykzFbqZRQSg1RrueOzuqOE',
    appId: '1:631985219642:ios:aa3587e71b0138c0986d03',
    messagingSenderId: '631985219642',
    projectId: 'rescue-alert-prod-12345',
    storageBucket: 'rescue-alert-prod-12345.firebasestorage.app',
    iosBundleId: 'com.example.rescueApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAKl7I7GegtmykzFbqZRQSg1RrueOzuqOE',
    appId: '1:631985219642:ios:aa3587e71b0138c0986d03',
    messagingSenderId: '631985219642',
    projectId: 'rescue-alert-prod-12345',
    storageBucket: 'rescue-alert-prod-12345.firebasestorage.app',
    iosBundleId: 'com.example.rescueApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDKVqBWCnBqz2xmebtiD-6VOEHkT4z_zMc',
    appId: '1:631985219642:web:4d8e71d2efa6f7ec986d03',
    messagingSenderId: '631985219642',
    projectId: 'rescue-alert-prod-12345',
    authDomain: 'rescue-alert-prod-12345.firebaseapp.com',
    storageBucket: 'rescue-alert-prod-12345.firebasestorage.app',
  );

}