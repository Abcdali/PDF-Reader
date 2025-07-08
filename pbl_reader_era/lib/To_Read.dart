// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'Diamond.dart';
// import 'Books.dart';
//
// class ToRead {
//   final String id;
//   final String title;
//   final List<String> authors;
//   final String description;
//   final String? thumbnail;
//   final int? pageCount;
//   final String language;
//   final String? previewLink;
//
//   ToRead({
//     required this.id,
//     required this.title,
//     required this.authors,
//     required this.description,
//     this.thumbnail,
//     this.pageCount,
//     required this.language,
//     this.previewLink,
//   });
//
//   factory ToRead.fromBook(Book book) {
//     return ToRead(
//       id: book.id,
//       title: book.title,
//       authors: book.authors,
//       description: book.description,
//       thumbnail: book.thumbnail,
//       pageCount: book.pageCount,
//       language: book.language,
//       previewLink: book.previewLink,
//     );
//   }
// }
//
// class ToReads extends StatefulWidget {
//   @override
//   State<ToReads> createState() => _FavoriteBooksState();
// }
//
// class _FavoriteBooksState extends State<ToReads> {
//   final User? person = FirebaseAuth.instance.currentUser;
//
//   Future<void> _openBook(String? previewLink) async {
//     if (previewLink != null && previewLink.isNotEmpty) {
//       final Uri url = Uri.parse(previewLink);
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Could not open book')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Preview not available')),
//       );
//     }
//   }
//
//   void _removeFromRead(String bookId) {
//     setState(() {
//       recentManager.removeFromread(bookId);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Book removed from To Read'),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<ToRead> readBooks = recentManager.getReadBooks();
//
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF1E3A8A),
//               Color(0xFF3B82F6),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   children: [
//                     Builder(
//                       builder: (context) => Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black26,
//                               blurRadius: 8,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: IconButton(
//                           icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Recent Read",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.2,
//                               shadows: [
//                                 Shadow(
//                                   blurRadius: 10.0,
//                                   color: Colors.black.withOpacity(0.3),
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 8,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: IconButton(
//                         icon: Icon(Icons.diamond_outlined, size: 24, color: Colors.white),
//                         onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => Diamond()),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 "Recently",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.2,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 10.0,
//                       color: Colors.black.withOpacity(0.3),
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 "${readBooks.length} Read books",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white70,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               SizedBox(height: 30),
//               Expanded(
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: readBooks.isEmpty
//                       ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.favorite_border, size: 64, color: Colors.white54),
//                         SizedBox(height: 16),
//                         Text(
//                           "No Read books yet",
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           "Start adding books to your Read!",
//                           style: TextStyle(color: Colors.white70, fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   )
//                       : ListView.builder(
//                     itemCount: readBooks.length,
//                     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
//                     itemBuilder: (context, index) {
//                       final book = readBooks[index];
//                       return Card(
//                         color: Colors.white.withOpacity(0.95),
//                         margin: const EdgeInsets.symmetric(vertical: 6),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                         elevation: 8,
//                         shadowColor: Colors.black.withOpacity(0.2),
//                         child: InkWell(
//                           onTap: () => _openBook(book.previewLink),
//                           borderRadius: BorderRadius.circular(16),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(6),
//                                   child: book.thumbnail != null
//                                       ? Image.network(
//                                     book.thumbnail!,
//                                     height: 120,
//                                     width: 80,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
//                                   )
//                                       : _buildPlaceholderCover(),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         book.title,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF1E3A8A),
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       const SizedBox(height: 4),
//                                       if (book.authors.isNotEmpty)
//                                         Text(
//                                           "By: ${book.authors.join(', ')}",
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             fontSize: 12,
//                                             fontStyle: FontStyle.italic,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         "Pages: ${book.pageCount ?? 'N/A'} | ${book.language.toUpperCase()}",
//                                         style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       if (book.description.isNotEmpty)
//                                         Text(
//                                           book.description,
//                                           style: TextStyle(
//                                             color: Colors.grey[700],
//                                             fontSize: 11,
//                                           ),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         children: [
//                                           IconButton(
//                                             icon: Icon(Icons.favorite),
//                                             color: Colors.red,
//                                             onPressed: () => _removeFromRead(book.id),
//                                             tooltip: 'Remove from favorites',
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholderCover() {
//     return Container(
//       height: 120,
//       width: 80,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: const Icon(Icons.menu_book, color: Colors.white, size: 40),
//     );
//   }
// }
//
// class recentManager {
//   static List<ToRead> _read = [];
//
//   static List<ToRead> getReadBooks() {
//     return _read;
//   }
//
//   static bool isread(String bookId) {
//     return _read.any((book) => book.id == bookId);
//   }
//
//   static void addToRead(Book book) {
//     if (!isread(book.id)) {
//       _read.add(ToRead.fromBook(book));
//     }
//   }
//
//   static void removeFromread(String bookId) {
//     _read.removeWhere((book) => book.id == bookId);
//   }
//
//   static void toggle_to_read(Book book) {
//     if (isread(book.id)) {
//       removeFromread(book.id);
//     } else {
//       addToRead(book);
//     }
//   }
// }
