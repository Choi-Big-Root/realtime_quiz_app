import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realtime_quiz_app/quiz_app/pin_code_page.dart';
import 'package:realtime_quiz_app/web/quiz_manager_page.dart';
import 'firebase_options.dart';

late FirebaseDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        '${defaultTargetPlatform == TargetPlatform.android ? dotenv.env['FIREBASE_ANDROID_DATABASE_HOST'] : dotenv.env['FIREBASE_DATABASE_HOST']}?ns=${dotenv.env['FIREBASE_DATABASE_PROJECT_ID']}',
  );

  await FirebaseAuth.instance.useAuthEmulator(
    dotenv.env['FIREBASE_AUTH_BASEURL']!,
    int.parse(dotenv.env['FIREBASE_AUTH_PORT']!),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kIsWeb ? 'Real Quiz Web' : 'Real Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: kIsWeb ? const QuizManagerPage() : const PinCodePage(),
    );
  }
}
