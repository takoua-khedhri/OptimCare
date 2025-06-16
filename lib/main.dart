import 'package:flutter/foundation.dart'; // pour kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Home.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ajoute cette importation en haut


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // ✅ Configuration Firebase pour le Web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCzSaCJWy7uKbhGbR_hDIlAlscM8Y1nJZ8",
          authDomain: "nurseapp-35dfd.firebaseapp.com",
          projectId: "nurseapp-35dfd",
          storageBucket: "nurseapp-35dfd.appspot.com",
          messagingSenderId: "856278140776",
          appId: "1:856278140776:web:30edf12a7a479fa38378dd",
          measurementId: "G-NVLSE6YWFP",
        ),
      );
    } else {
      // ✅ Configuration Firebase pour Android (ou iOS si tu ajoutes iOS plus tard)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB5zn864VLPKoHsZzBTaWuOaXNglHES6yI",
          projectId: "nurseapp-35dfd",
          storageBucket: "nurseapp-35dfd.appspot.com",
          messagingSenderId: "856278140776",
          appId: "1:856278140776:android:95d218708a898a788378dd",
        ),
      );
    }
  } catch (e) {
    print("Erreur Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr'),
      supportedLocales: const [
        Locale('en'), // anglais
        Locale('fr'), // français
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WelcomePage(),
    );
  }
}
