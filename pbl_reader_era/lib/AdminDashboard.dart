import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as Math;

import 'Book_preview.dart';
import 'Login.dart';
import 'Recent_Manager.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboard();
}

class _AdminDashboard extends State<AdminDashboard> {
  int index = 0;
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

  void item(int value) {
    setState(() {
      index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _isLoading
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      Transform.translate(
        offset: const Offset(130, 100),
        child: Container(
          width: 150,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/user.jpeg"),
              ),
              Transform.translate(
                offset: const Offset(0, 70),
                child: const Text(
                  "Admin@example.com",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 150),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                          (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully Logged Out"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    "LOG OUT",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: item,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: 30), label: "Account"),
        ],
      ),
    );
  }
}
