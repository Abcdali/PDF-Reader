import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'Book_preview.dart';
import 'read_manager.dart';

class HaveRead extends StatefulWidget {
  @override
  _HaveRead createState() => _HaveRead();
}

class _HaveRead extends State<HaveRead> {
  final ReadManager Read = ReadManager();
  bool _isLoading = true;
  List<String> favoriteFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRead();
  }

  Future<void> _loadRead() async {
    await Read.loadFavorites();
    setState(() {
      favoriteFiles =  Read.favoritePaths.toList()..sort();
      _isLoading = false;
    });
  }

  void _handleReadToggle(String filePath) async {
    await  Read.toggleRead(filePath);
    await  Read.loadFavorites(); // Refresh after toggle

    setState(() {
      favoriteFiles =  Read.favoritePaths.toList()..sort();
    });

    final updated =  Read.isRead(filePath); // FIXED HERE
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated
            ? "Added to 'Have Read'"
            : "Removed from 'Have Read'"),
        backgroundColor: updated ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text("Have Read",style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20),),
          flexibleSpace: Container(
            decoration: BoxDecoration(
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteFiles.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'Books and documents that you added\n'
                'to the Have Read section will be here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      )
          : ListView.builder(
        itemCount: favoriteFiles.length,
        itemBuilder: (context, index) {
          final filePath = favoriteFiles[index];
          final fileName = path.basename(filePath);
          final file = File(filePath);
          final fileSize = file.existsSync()
              ? formatBytes(file.lengthSync())
              : 'Unknown Size';
          final bool isFavorite =
          Read.isRead(filePath); // FIXED HERE

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf,
                          color: Colors.redAccent, size: 50),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(fileName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("File Size: $fileSize"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
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
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            size: 30),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 100.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite_border),
                            onPressed: (){},
                          ),
                          IconButton(
                            icon: Icon(Icons.history),
                            color: Color(0xFF1E3A8A),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Read.isRead(filePath)
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                            ),
                            color: isFavorite
                              ? Color(0xFFD7B338)
                                :  Color(0xFF1E3A8A),
                            onPressed: () =>
                                _handleReadToggle(filePath),
                          ),
                          IconButton(
                            icon:
                            Icon(Icons.library_books_outlined),
                            color: Color(0xFF1E3A8A),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            color: Color(0xFF1E3A8A),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
      ),
    );
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
