import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn? _googleSignIn;
  String? _error;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_CLIENT_ID'],
      scopes: ['email', drive.DriveApi.driveScope,],
    );

    // try silent login (biar gak popup tiap kali)
    _googleSignIn!.signInSilently().then((account) {
      if (account != null) {
        _checkAccess(account.email);
      }
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final account = await _googleSignIn!.signIn();
      if (account != null) {
        _checkAccess(account.email);
      }
    } catch (e) {
      setState(() => _error = "Login failed: $e");
    }
  }

  void _checkAccess(String email) {
    final allowed = dotenv.env['ADMIN_EMAILS']?.split(',') ?? [];
    if (allowed.contains(email)) {
      Navigator.pushReplacementNamed(context, '/upload');
    } else {
      setState(() => _error = "Access denied for $email");
      _googleSignIn?.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "CiwAI Drive",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: const Text("Login with Google"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
