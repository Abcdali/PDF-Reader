import 'package:flutter/material.dart';
import 'deleted_manager.dart';
import 'dart:io';

class DeletedFilesScreen extends StatefulWidget {
  const DeletedFilesScreen({Key? key}) : super(key: key);

  @override
  State<DeletedFilesScreen> createState() => _DeletedFilesScreenState();
}

class _DeletedFilesScreenState extends State<DeletedFilesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DeletedManager().loadDeleted().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  String extractFileName(String path) {
    return path.split('/').last;
  }

  Future<String> getFileSizeFormatted(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final bytes = await file.length();
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    }
    return "File not found";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Deleted Files",style: TextStyle(
                       color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<String>>(
        valueListenable: DeletedManager.deletedNotifier,
        builder: (context, deletedFiles, _) {
          if (deletedFiles.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  'No deleted files yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: deletedFiles.length,
            itemBuilder: (context, index) {
              final filePath = deletedFiles[index];
              final fileName = extractFileName(filePath);

              return FutureBuilder<String>(
                future: getFileSizeFormatted(filePath),
                builder: (context, snapshot) {
                  final fileSize = snapshot.data ?? "Loading...";

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.insert_drive_file, color: Colors.redAccent, size: 50),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(fileName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("File Size: $fileSize"),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.restore, color: Colors.green),
                                tooltip: "Restore File",
                                onPressed: () async {
                                  await DeletedManager().removeFromDeleted(filePath);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("File restored"),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
