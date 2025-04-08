import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realtime_quiz_app/web/quiz_manager_page.dart';
import 'firebase_options.dart';

FirebaseDatabase? database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? host;
  String? baseUrl;

  host = dotenv.env['FIREBASE_DATABASE_HOST'];
  baseUrl = dotenv.env['FIREBASE_AUTH_BASEURL'];

  database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: '$host/?ns=${dotenv.env['FIREBASE_DATABASE_PROJECT_ID']}',
  );

  await FirebaseAuth.instance.useAuthEmulator(
    baseUrl!,
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const QuizManagerPage();
  }
}
