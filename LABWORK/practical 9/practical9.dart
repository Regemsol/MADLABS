import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
const _firebaseMessagingSenderId =
    String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const _firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
const _firebaseObjectPath = 'practical9/practical9_sample.txt';

bool get _hasFirebaseConfiguration =>
    _firebaseApiKey.isNotEmpty &&
    _firebaseAppId.isNotEmpty &&
    _firebaseMessagingSenderId.isNotEmpty &&
    _firebaseProjectId.isNotEmpty &&
    _firebaseStorageBucket.isNotEmpty;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseEnabled = false;
  var firebaseMessage = 'Firebase Storage is available on the web target.';
  if (kIsWeb) {
    if (_hasFirebaseConfiguration) {
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: _firebaseApiKey,
            appId: _firebaseAppId,
            messagingSenderId: _firebaseMessagingSenderId,
            projectId: _firebaseProjectId,
            storageBucket: _firebaseStorageBucket,
          ),
        );
        firebaseEnabled = true;
        firebaseMessage = 'Firebase Storage connected.';
      } catch (error) {
        firebaseMessage = 'Firebase initialization failed: $error';
      }
    } else {
      firebaseMessage =
          'Firebase is not configured. Pass your Firebase web app values using --dart-define.';
    }
  } else {
    firebaseMessage = 'Firebase cloud sync is currently enabled for web only.';
  }

  runApp(
    PracticalNineApp(
      firebaseEnabled: firebaseEnabled,
      firebaseMessage: firebaseMessage,
    ),
  );
}

class PracticalNineApp extends StatelessWidget {
  const PracticalNineApp({
    super.key,
    required this.firebaseEnabled,
    required this.firebaseMessage,
  });

  final bool firebaseEnabled;
  final String firebaseMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practical 9: File I/O',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: FileIoPage(
        firebaseEnabled: firebaseEnabled,
        firebaseMessage: firebaseMessage,
      ),
    );
  }
}

class FileIoPage extends StatefulWidget {
  const FileIoPage({
    super.key,
    required this.firebaseEnabled,
    required this.firebaseMessage,
  });

  final bool firebaseEnabled;
  final String firebaseMessage;

  @override
  State<FileIoPage> createState() => _FileIoPageState();
}

class _FileIoPageState extends State<FileIoPage> {
  late final Future<Directory>? _documentsDirectoryFuture;
  late final Future<String> _storageLocationFuture;
  late Future<String> _fileContentFuture;

  static const _fileName = 'practical9_sample.txt';
  static const _sampleContent =
      'Hello from Flutter!\nThis text was written to a file in the app documents directory.';

  @override
  void initState() {
    super.initState();
    _documentsDirectoryFuture = kIsWeb ? null : _getDocumentsDirectory();
    _storageLocationFuture = _getStorageLocation();
    _fileContentFuture = _readFile();
  }

  Future<Directory> _getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    debugPrint('Application documents directory: ${directory.path}');
    return directory;
  }

  Future<String> _getStorageLocation() async {
    if (kIsWeb) return 'Browser local storage';
    final directory = await _documentsDirectoryFuture!;
    return '${directory.path}/$_fileName';
  }

  Future<File> _getSampleFile() async {
    final directory = await _documentsDirectoryFuture!;
    return File('${directory.path}/$_fileName');
  }

  Future<void> _saveLocalContent(String content) async {
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_fileName, content);
    } else {
      final file = await _getSampleFile();
      await file.writeAsString(content);
    }
  }

  Future<String> _readFile() async {
    try {
      if (kIsWeb) {
        final preferences = await SharedPreferences.getInstance();
        final content = preferences.getString(_fileName);
        if (content == null) {
          throw StateError('No sample content has been saved yet.');
        }
        return content;
      }
      final file = await _getSampleFile();
      return await file.readAsString();
    } catch (error) {
      throw StateError('Could not read $_fileName: $error');
    }
  }

  Future<void> _writeFile() async {
    try {
      await _saveLocalContent(_sampleContent);
      if (!mounted) return;
      setState(() {
        _fileContentFuture = _readFile();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Sample saved in browser storage.'
                : 'Sample file written successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not write $_fileName: $error')),
      );
    }
  }

  Future<void> _uploadToFirebase() async {
    try {
      final content = await _readFile();
      await FirebaseStorage.instance.ref(_firebaseObjectPath).putString(
            content,
            format: PutStringFormat.raw,
            metadata: SettableMetadata(contentType: 'text/plain'),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded to Firebase Storage.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase upload failed: $error')),
      );
    }
  }

  Future<void> _downloadFromFirebase() async {
    try {
      final data = await FirebaseStorage.instance
          .ref(_firebaseObjectPath)
          .getData(1024 * 1024);
      if (data == null) {
        throw StateError('The Firebase object is empty or unavailable.');
      }
      await _saveLocalContent(utf8.decode(data));
      if (!mounted) return;
      setState(() {
        _fileContentFuture = _readFile();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File downloaded from Firebase Storage.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase download failed: $error')),
      );
    }
  }

  void _refreshFile() {
    setState(() {
      _fileContentFuture = _readFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practical 9: File I/O')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.folder_open, size: 56, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              'Work with a text file',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb
                  ? 'Web stores this sample in browser storage, not a device file.'
                  : 'The sample is saved in the app documents directory.',
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<String>(
                  future: _storageLocationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Directory error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    return SelectableText(
                      'Storage location\n${snapshot.data}',
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _writeFile,
                  icon: const Icon(Icons.save),
                  label: Text(kIsWeb ? 'Save sample' : 'Write sample file'),
                ),
                OutlinedButton.icon(
                  onPressed: _refreshFile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Read file'),
                ),
                FilledButton.tonalIcon(
                  onPressed: widget.firebaseEnabled ? _uploadToFirebase : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload to Firebase'),
                ),
                OutlinedButton.icon(
                  onPressed: widget.firebaseEnabled ? _downloadFromFirebase : null,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Download from Firebase'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.firebaseMessage),
            if (widget.firebaseEnabled)
              const SelectableText('Firebase object: $_firebaseObjectPath'),
            const SizedBox(height: 20),
            Text('File contents', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<String>(
                  future: _fileContentFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text(
                        kIsWeb
                            ? 'No saved content yet. Save the sample to create it.\n\n${snapshot.error}'
                            : 'Unable to load the file. Write the sample file to create it.\n\n${snapshot.error}',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      );
                    }
                    return SelectableText(
                      snapshot.data ?? 'The file is empty.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}