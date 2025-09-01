import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/login_screen.dart';
import 'features/upload/upload_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
await dotenv.load(fileName: "env.json");
  runApp(const CiwaiDriveApp());

  print("ENV Loaded: ${dotenv.env}");

}

class CiwaiDriveApp extends StatelessWidget {
  const CiwaiDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CiwAI Drive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
home: const LoginScreen(),
      routes: {
        '/upload': (context) => const UploadScreen(),
      },
    );
  }
}
