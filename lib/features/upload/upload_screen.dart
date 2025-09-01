import 'dart:html' as html; // File picker for Flutter Web
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  GoogleSignInAccount? _user;
  bool _uploading = false;
  String? _status;
  String? _fileLink;

  @override
  void initState() {
    super.initState();
    _restoreUser();
  }

  Future<void> _restoreUser() async {
    final googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_CLIENT_ID'],
      scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
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

          final googleSignIn = GoogleSignIn(
            clientId: dotenv.env['GOOGLE_CLIENT_ID'],
            scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
          );
          final account = await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
          final auth = await account?.authHeaders;

          if (auth == null) {
            setState(() {
              _uploading = false;
              _status = "Not authenticated.";
            });
            return;
          }

          final folderId = dotenv.env['DRIVE_FOLDER_ID'];

          // Metadata JSON
          final metadata = {
            'name': file.name,
            'parents': [folderId]
          };

          // Multipart upload (metadata + file)
          final request = http.MultipartRequest(
            'POST',
            Uri.parse("https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"),
          );

          request.headers.addAll(auth);
          request.fields['metadata'] = jsonEncode(metadata);

          request.files.add(http.MultipartFile.fromBytes(
            'file',
            reader.result as List<int>,
            filename: file.name,
          ));

          final response = await request.send();
          final respStr = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            final jsonResp = jsonDecode(respStr);
            final fileId = jsonResp['id'];
            setState(() {
              _uploading = false;
              _status = "Upload successful!";
              _fileLink = "https://drive.google.com/file/d/$fileId/view";
            });
          } else {
            setState(() {
              _uploading = false;
              _status = "Upload failed: ${response.statusCode}";
            });
          }
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
