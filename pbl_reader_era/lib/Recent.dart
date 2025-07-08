import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'Book_preview.dart';
import 'Recent_Manager.dart';

class RecentFilesWidget extends StatefulWidget {
  const RecentFilesWidget({super.key});

  @override
  _RecentFilesWidgetState createState() => _RecentFilesWidgetState();
}

class _RecentFilesWidgetState extends State<RecentFilesWidget> {
  bool _isLoading = true;
  List<String> recentFiles = [];
  final RecentManager recentManager = RecentManager();

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    await recentManager.loadRecent();
    setState(() {
      recentFiles = RecentManager.recentNotifier.value;
      _isLoading = false;
    });
  }

  String extractFileName(String path) {
    return path.split('/').last;
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }

  Future<String> getFileSizeFormatted(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return "File not found";
      final bytes = await file.length();
      return formatBytes(bytes);
    } catch (e) {
      return "Error reading file";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Recently Opened",style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20),),
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
          : recentFiles.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'No recent files opened yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      )
          : ListView.builder(
        itemCount: recentFiles.length,
        itemBuilder: (context, index) {
          final filePath = recentFiles[index];
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
                          const Icon(Icons.picture_as_pdf,
                              color: Colors.redAccent, size: 50),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                RecentManager.addToRecent(filePath);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewerScreen(
                                      pdfPath: filePath,
                                      pdfName: fileName,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fileName,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("File Size: $fileSize"),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 30),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 100.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                color: const Color(0xFF1E3A8A),
                                onPressed: () {

                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  recentManager.isRecent(filePath)
                                      ? Icons.history
                                      : Icons.history_outlined,
                                ),
                                color: recentManager.isRecent(filePath)
                                    ? const Color(0xFFD7B338)
                                    : const Color(0xFF1E3A8A),
                                tooltip: recentManager.isRecent(filePath)
                                    ? "Marked as Recent"
                                    : "Mark as Recent",
                                onPressed: () async {
                                  await recentManager.toggleRecent(filePath);
                                  await recentManager.loadRecent();
                                  setState(() {
                                    recentFiles = RecentManager.recentNotifier.value;
                                  });

                                  final updated = recentManager.isRecent(filePath);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        updated
                                            ? "Added to Recent"
                                            : "Removed from Recent",
                                      ),
                                      backgroundColor: updated
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                color: const Color(0xFF1E3A8A),
                                onPressed: () {

                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.library_books_outlined),
                                color: const Color(0xFF1E3A8A),
                                onPressed: () {

                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                color: const Color(0xFF1E3A8A),
                                onPressed: () {

                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF1E3A8A),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
