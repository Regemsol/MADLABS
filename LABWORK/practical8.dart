import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Libraries and Files',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FilePage(),
    );
  }
}

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {

  // Simulated file content
  String fileContent = '';

  // Simulate reading a file asynchronously
  Future<String> readFile() async {
    await Future.delayed(const Duration(seconds: 1));

    // Sample text that represents file content
    return 'Hello from Flutter!\n'
        'This is sample text stored in a file.\n'
        'File operations can be performed asynchronously.';
  }

  // Simulate writing to a file
  Future<void> writeFile() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      fileContent = 'File written successfully!\n'
          'Name: Flutter Lab\n'
          'Topic: File Handling';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libraries & File Handling'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Icon(
              Icons.folder,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              'File Handling in Flutter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Display simulated file path
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Text(
                'File Path:\n'
                '/documents/flutter_lab.txt',

                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Write Button
            ElevatedButton.icon(
              onPressed: writeFile,

              icon: const Icon(Icons.edit),

              label: const Text('Write File'),
            ),

            const SizedBox(height: 10),

            // Read Button
            ElevatedButton.icon(
              onPressed: () {

                setState(() {
                  fileContent = '';
                });

                readFile().then((data) {

                  setState(() {
                    fileContent = data;
                  });

                }).catchError((error) {

                  setState(() {
                    fileContent = 'Error reading file: $error';
                  });

                });
              },

              icon: const Icon(Icons.folder_open),

              label: const Text('Read File'),
            ),

            const SizedBox(height: 25),

            // FutureBuilder
            Expanded(
              child: FutureBuilder<String>(
                future: readFile(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {

                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue,
                      ),
                    ),

                    child: Text(
                      fileContent.isEmpty
                          ? snapshot.data ?? 'No file content'
                          : fileContent,

                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}