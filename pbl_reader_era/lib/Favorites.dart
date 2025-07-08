import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'Book_preview.dart';
import 'favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}
class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesManager favoritesManager = FavoritesManager();
  bool _isLoading = true;
  List<String> favoriteFiles = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await favoritesManager.loadFavorites();
    setState(() {
      favoriteFiles = favoritesManager.favoritePaths.toList()..sort();
      _isLoading = false;
    });
  }

  void _handleFavoriteToggle(String filePath) async {
    await favoritesManager.toggleFavorite(filePath);
    await favoritesManager.loadFavorites(); // Refresh after toggle

    setState(() {
      favoriteFiles = favoritesManager.favoritePaths.toList()..sort();
    });

    final updated = favoritesManager.isFavorite(filePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated
            ? "Added to Favorites"
            : "Removed from Favorites"),
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
          title: Text("Favorites",style: TextStyle(
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
          : Container(
        child: favoriteFiles.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border,
                  size: 100,color: Color(0xFF1E3A8A)),
              SizedBox(height: 20),
              Text(
                'No favorites yet.',
                style:
                TextStyle(fontSize: 18, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                'Add files to favorites by tapping the heart icon',
                style:
                TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
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
            favoritesManager.isFavorite(filePath);

            return Card(
              color: Colors.white,
              margin:
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                builder: (context) =>
                                    PdfViewerScreen(
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
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              color: isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                              onPressed: () =>
                                  _handleFavoriteToggle(filePath),
                            ),
                            IconButton(
                              icon: Icon(Icons.history),
                              color: Color(0xFF1E3A8A),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.check_circle_outline),
                              color: Color(0xFF1E3A8A),
                              onPressed: () {},
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
      ),
    );
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }
}
