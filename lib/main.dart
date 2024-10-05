import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'math_tutor_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  await dotenv.load(fileName: ".env"); // Load environment variables
  runApp(ProviderScope(child: MatzApp()));
}

class MatzApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatzApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MathTutorScreen(),
    );
  }
}
