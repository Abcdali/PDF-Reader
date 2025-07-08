import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as path;
import 'package:pbl_reader_era/read_manager.dart';
import 'package:pbl_reader_era/readera.dart';
import 'Book_preview.dart';
import 'Diamond.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Favorites.dart';
import 'package:pbl_reader_era/favorites_manager.dart';
import 'Have_Read.dart';
import 'Login.dart';
import 'Recent.dart';
import 'Recent_Manager.dart';
import 'data/models/book_detail.dart';
import 'delete.dart';
import 'deleted_manager.dart';
import 'folder.dart';

class Book_documents extends StatefulWidget {
  @override
  State<Book_documents> createState() => _Book_documents();
}

class _Book_documents extends State<Book_documents> with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final User? person = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  List<String> _pdfFiles = [];
  List<String> _filteredFiles = [];
  List<Map<String, String>> Fav = [];
  final ReadManager Read = ReadManager();
  bool _isSearching = false;
  final FavoritesManager favoritesManager = FavoritesManager();
  final RecentManager recentManager = RecentManager();
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _initializeFavorites();
    requestPermissionsAndScan();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  Future<void> _initializeFavorites() async {
    await favoritesManager.loadFavorites();
    setState(() {});
  }

  Future<void> requestPermissionsAndScan() async {
    if (await Permission.manageExternalStorage.isGranted) {
      print("Manage External Storage permission granted");
      await scanPDFs();
    } else {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        print("Manage External Storage permission granted after request");
        await scanPDFs();
      } else {
        if (await Permission.storage.isGranted) {
          print("Storage permission granted");
          await scanPDFs();
        } else {
          var storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) {
            print("Storage permission granted after request");
            await scanPDFs();
          } else {
            print("Permission denied. Please grant storage permission manually.");
            bool opened = await openAppSettings();
            if (opened) {
              print("Opened app settings, please grant permission manually.");
            }
          }
        }
      }
    }
  }

  Future<void> scanPDFs() async {
    print("Permission granted, scanning PDFs...");
    _pdfFiles.clear();
    _filteredFiles.clear();
    await getPDFFilesWithSkip("/storage/emulated/0/");
    setState(() {
      _filteredFiles = List.from(_pdfFiles);
    });
  }

  Future<void> getPDFFilesWithSkip(String dirPath) async {
    final restrictedFolders = [
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/obb',
    ];
    final directory = Directory(dirPath);

    try {
      if (!await directory.exists()) {
        print("Directory does not exist: $dirPath");
        return;
      }

      await for (final entity in directory.list(followLinks: false)) {
        final entityPath = entity.path;

        if (entity is Directory) {
          if (restrictedFolders.any((restrictedPath) => entityPath.startsWith(restrictedPath))) {
            continue;
          }
          await getPDFFilesWithSkip(entityPath);
        } else if (entity is File) {
          if (entityPath.toLowerCase().endsWith('.pdf') || entityPath.toLowerCase().endsWith('.epub')) {
            setState(() {
              _pdfFiles.add(entityPath);
            });
          }
        }
      }
    } catch (e) {
      print("Error accessing directory $dirPath: $e");
    }
  }


  void _filterFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFiles = List.from(_pdfFiles);
      } else {
        _filteredFiles = _pdfFiles.where((file) =>
            path.basename(file).toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }

  final DeletedManager deletedManager = DeletedManager();

  void deleteDocument(int index) async {
    String filePath = _filteredFiles[index];

    setState(() {
      _pdfFiles.remove(filePath);
      _filteredFiles.removeAt(index);
    });


    await deletedManager.addToDeleted(filePath);
  }



  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  final Set<String> _favoritePaths = {};

  Set<String> get favoritePaths => _favoritePaths;

  bool isFavorite(String path) => _favoritePaths.contains(path);
  PreferredSizeWidget customAppBar(BuildContext context, VoidCallback onSearchToggle) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      elevation: 0,
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: Colors.black, size: 30),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _isSearching
                        ? TextField(
                      key: ValueKey('searchField'),
                      controller: _searchController,
                      style: TextStyle(color: Colors.black),
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _filterFiles(value);
                      },
                    )
                        : Text(
                      "Books & Doc..",
                      key: ValueKey('titleText'),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),


                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.diamond_outlined,size: 30, color: Colors.black),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Diamond()),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(_isSearching ? Icons.close : Icons.search, size: 30, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchController.clear();
                            _filteredFiles = List.from(_pdfFiles);
                          }
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.more_vert, size: 30, color: Colors.black),
                      onPressed: () async {
                        final selected = await showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          items: [
                            PopupMenuItem(
                              child: GestureDetector(

                                onTap: (){
                                  _ShareAlert(context);
                                },
                                child: Text(
                                  'Share the reader',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );

                        if (selected == 'share') {

                        }
                      },
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Logged in user: ${person?.email ?? person?.phoneNumber ?? 'Guest'}");

    return Scaffold(
      appBar: customAppBar(context, () {
        setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) {
            _searchController.clear();
            _filteredFiles = List.from(_pdfFiles);
          }
        });
      }),
      drawer: AppDrawer(onLogout: _logout, person: person),
      body: _filteredFiles.isEmpty
          ? Center(child: Text("Scanning Files....",style: TextStyle(fontSize: 20),))
          : ListView.builder(
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          // final book = books[index];
          String filePath = _filteredFiles[index];
          String fileName = path.basename(filePath);
          int fileSizeInBytes = File(filePath).lengthSync();
          String fileSize = formatBytes(fileSizeInBytes);

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
                      SizedBox(
                        width: 50,
                        height: 60,
                        child: Icon(
                          fileName.toLowerCase().endsWith('.pdf')
                              ? Icons.picture_as_pdf
                              : Icons.menu_book_sharp,
                          color: fileName.toLowerCase().endsWith('.epub')
                              ? Colors.green
                              : Colors.redAccent,
                          size: 50,
                        ),
                      ),

                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            RecentManager.addToRecent(filePath);
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>PdfViewerScreen( pdfPath: filePath,
                              pdfName: fileName,)));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fileName, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("File Size: $fileSize"),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _controller.forward().then((_) {
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
                            _controller.reset();
                          });
                        },
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          // child: Icon(Icons.arrow_forward_ios_rounded, size: 30),
                        ),
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
                          ValueListenableBuilder<Set<String>>(
                            valueListenable: favoritesManager.favoritesNotifier,
                            builder: (context, favoritePaths, _) {
                              final isFavorite = favoritePaths.contains(filePath);

                              return IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Color(0xFF1E3A8A),
                                ),
                                onPressed: () async {
                                  await favoritesManager.toggleFavorite(filePath);


                                  final updated = favoritesManager.isFavorite(filePath);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        updated ? "Added to Favorites" : "Removed from Favorites",
                                      ),
                                      backgroundColor: updated ? Colors.green : Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              recentManager.isRecent(filePath)
                                  ? Icons.history
                                  : Icons.history_outlined,
                            ),
                            color: recentManager.isRecent(filePath)
                                ? Color(0xFFD7B338)
                                : Color(0xFF1E3A8A),
                            tooltip: recentManager.isRecent(filePath)
                                ? "Marked as Recent"
                                : "Mark as Recent",
                            onPressed: () async {
                              await recentManager.toggleRecent(filePath);
                              await recentManager.loadRecent();
                              setState(() {});

                              final updated = recentManager.isRecent(filePath);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    updated ? "Added to Recent" : "Removed from Recent",
                                  ),
                                  backgroundColor: updated ? Colors.green.shade700 : Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Read.isRead(filePath)
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                            ),
                            color: Read.isRead(filePath) ? Color(0xFFD7B338)
                                : Color(0xFF1E3A8A),
                            tooltip: Read.isRead(filePath)
                                ? "Marked as Read"
                                : "Mark as Read",
                            onPressed: () async {
                              await Read.toggleRead(filePath);
                              await Read.loadFavorites();
                              setState(() {}); // Update UI

                              final updated = Read.isRead(filePath);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    updated
                                        ? "Added to 'Have Read'"
                                        : "Removed from 'Have Read'",
                                  ),
                                  backgroundColor: updated ? Colors.green.shade700 : Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),


                          IconButton(
                            icon: Icon(Icons.delete_forever),
                            color: Colors.redAccent,
                            onPressed: () {
                              deleteDocument(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Successfully Deleted"
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                              ),
                          IconButton(
                            icon: Icon(Icons.info_outline,color: Color(0xFF1E3A8A)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDisplayScreen(bookTitle:path.basenameWithoutExtension(fileName)),
                                ),
                              );
                            },
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
}


class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final User? person;

  const AppDrawer({required this.onLogout, required this.person, Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(

        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/images/user.jpeg"),
                  ),
                ),
                accountName: Text(""),
                accountEmail: Text(
                  person?.email ?? person?.phoneNumber ?? 'Guest',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => readera()),
                );
              },
              title: Text("ReadEra", style: TextStyle(fontSize: 18, color:Color(0xFF1E3A8A))),
              leading: Icon(Icons.book_outlined,  color: Color(0xFF1E3A8A), size: 30),
            ),
            ListTile(
              title: Text("Recently Open", style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.repeat,   color: Color(0xFF1E3A8A), size: 30),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>RecentFilesWidget()));
              },
            ),
            ListTile(
              title: Text("Books & Documents", style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.document_scanner, color: Color(0xFF1E3A8A), size: 30),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Book_documents()));
              },
            ),
            ListTile(
              title: Text("Favorites", style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.star_border, color: Color(0xFF1E3A8A), size: 30),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>FavoritesScreen()));
              },
            ),
            ListTile(
              title: Text("Have Read", style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.check_circle_outline,  color: Color(0xFF1E3A8A), size: 30),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context)=>HaveRead()));
              },
            ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Folder()));
              },
              title: Text("Folders", style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.folder,  color: Color(0xFF1E3A8A), size: 30),
            ),
            ListTile(
              title: Text("Trash", style: TextStyle(fontSize: 18,color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.delete_forever_rounded,  color: Color(0xFF1E3A8A), size: 30),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=> DeletedFilesScreen()));
              },
            ),
            Padding(padding: EdgeInsets.all(10.0), child: Divider(height: 1, color:Color(0xFF1E3A8A).withOpacity(0.3))),
            ListTile(
              title: Text("Send Feedback", style: TextStyle(fontSize: 18, color:Color(0xFF1E3A8A))),
              leading: Icon(Icons.feedback,  color: Color(0xFF1E3A8A), size: 30),
              onTap: () {
                Navigator.pop(context);
                _Alert(context);
              },
            ),
            ListTile(
              title: Text("Sign Out", style: TextStyle(fontSize: 18,  color: Color(0xFF1E3A8A))),
              leading: Icon(Icons.settings,  color: Color(0xFF1E3A8A), size: 30),
              onTap: () {
                onLogout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("SignOut successfully"),
                    backgroundColor: Color(0xFF4ADE80),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
_ShareAlert(BuildContext context){
  showDialog(context: context, builder:(BuildContext context){
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Share", style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A)
      ),
        textAlign: TextAlign.center,),
      content: Text(
        "Reading books with ReadEra\n"
            "https://readera.org",
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        textAlign: TextAlign.center,
      ),
      actions: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4ADE80),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],

    );
  });
}
_Alert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Feedback about ReadEra\n",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A)
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "If you have questions, suggestions, or need troubleshooting, write to us at support@readera.org and we will try to figure it all out.",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4ADE80),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    },
  );
}