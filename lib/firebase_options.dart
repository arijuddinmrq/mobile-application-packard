import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
    apiKey: 'AIzaSyALK_az_S8p4-zciBTtG3fdAyIEFArBv7w',
    appId: '1:332734361468:web:a2eec09e33c488b149fef9',
    messagingSenderId: '332734361468',
    projectId: 'ml-revised',
    authDomain: 'ml-revised.firebaseapp.com',
    databaseURL: 'https://ml-revised-default-rtdb.firebaseio.com',
    storageBucket: 'ml-revised.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMZ5Il5HBFTG1XWDAcjdtMSY2bZYu1mlw',
    appId: '1:332734361468:android:286e81d99a3c4ed749fef9',
    messagingSenderId: '332734361468',
    projectId: 'ml-revised',
    databaseURL: 'https://ml-revised-default-rtdb.firebaseio.com',
    storageBucket: 'ml-revised.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjR0BsIFjv_xT3WEvjlIjakJ88A1UJ4iU',
    appId: '1:332734361468:ios:f3c3dd5b6ec7e52749fef9',
    messagingSenderId: '332734361468',
    projectId: 'ml-revised',
    databaseURL: 'https://ml-revised-default-rtdb.firebaseio.com',
    storageBucket: 'ml-revised.appspot.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjR0BsIFjv_xT3WEvjlIjakJ88A1UJ4iU',
    appId: '1:332734361468:ios:f3c3dd5b6ec7e52749fef9',
    messagingSenderId: '332734361468',
    projectId: 'ml-revised',
    databaseURL: 'https://ml-revised-default-rtdb.firebaseio.com',
    storageBucket: 'ml-revised.appspot.com',
    iosBundleId: 'com.example.myApp',
  );
}
