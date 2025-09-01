import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_browser.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  GoogleSignInAccount? _user;
  String? _status;
  bool _uploading = false;
  String? _fileLink;

  @override
  void initState() {
    super.initState();
    _restoreUser();
  }

  Future<void> _restoreUser() async {
    final googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_CLIENT_ID'],
      scopes: [
        'email',
        drive.DriveApi.driveFileScope,
      ],
    );
    final account = await googleSignIn.signInSilently();
    setState(() => _user = account);
  }

  Future<void> _pickAndUploadFile() async {
    final input = html.FileUploadInputElement()..accept = '*/*';
    input.click();

    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((e) async {
        try {
          setState(() {
            _uploading = true;
            _status = "Uploading ${file.name}...";
            _fileLink = null;
          });

          // Google Sign-In
          final googleSignIn = GoogleSignIn(
            clientId: dotenv.env['GOOGLE_CLIENT_ID'],
            scopes: [
              'email',
              drive.DriveApi.driveFileScope,
            ],
          );
          final account = await googleSignIn.signInSilently() ??
              await googleSignIn.signIn();

          if (account == null) {
            setState(() {
              _uploading = false;
              _status = "Not authenticated.";
            });
            return;
          }

          final authHeaders = await account.authHeaders;
          final client = authenticatedClient(
            http.BrowserClient(),
            AccessCredentials(
              AccessToken(
                'Bearer',
                authHeaders['Authorization']!.split(" ").last,
                DateTime.now().toUtc().add(const Duration(hours: 1)),
              ),
              null,
              [drive.DriveApi.driveFileScope],
            ),
          );

          final driveApi = drive.DriveApi(client);

          // Metadata
          final driveFile = drive.File()
            ..name = file.name
            ..parents = [dotenv.env['DRIVE_FOLDER_ID'] ?? ""];

          // Upload
          final media = drive.Media(
            (reader.result as List<int>).asStream(),
            (reader.result as List<int>).length,
          );

          final uploaded = await driveApi.files.create(
            driveFile,
            uploadMedia: media,
          );

          setState(() {
            _uploading = false;
            _status = "Upload successful!";
            _fileLink =
                "https://drive.google.com/file/d/${uploaded.id}/view?usp=sharing";
          });
        } catch (e) {
          setState(() {
            _uploading = false;
            _status = "Error: $e";
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CiwAI Drive - Upload")),
      body: Center(
        child: _user == null
            ? const Text("Not signed in")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_uploading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(_status ?? "Uploading..."),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _pickAndUploadFile,
                      icon: const Icon(Icons.upload),
                      label: const Text("Choose File & Upload"),
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: 12),
                      Text(_status!),
                    ],
                    if (_fileLink != null) ...[
                      const SizedBox(height: 12),
                      SelectableText(
                        _fileLink!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ]
                ],
              ),
      ),
    );
  }
}
