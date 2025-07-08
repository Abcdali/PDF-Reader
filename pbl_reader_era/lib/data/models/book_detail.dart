import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pbl_reader_era/data/models/google_book_api.dart';
import 'package:pbl_reader_era/data/models/book_model.dart' as book_model;
import '../../Book_preview.dart';
import 'book_database.dart';

class BookDisplayScreen extends StatefulWidget {
  final String bookTitle;

  const BookDisplayScreen({Key? key, required this.bookTitle}) : super(key: key);

  @override
  State<BookDisplayScreen> createState() => _BookDisplayScreenState();
}

class _BookDisplayScreenState extends State<BookDisplayScreen> {
  book_model.MetaData? book;
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadBookFromAPI();
    checkInsertedBooks();
  }

  Future<void> _loadBookFromAPI() async {
    try {
      final result = await GoogleBookAPI.fetchBookByTitle(widget.bookTitle);
      if (!mounted) return;
      if (result != null) {
        setState(() {
          book = result;
          loading = false;
        });
        await inserting_book(result);
        await _saveBookToFirestore(result);

      } else {
        setState(() {
          error = 'Book not found via Google API.';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching book: $e';
        loading = false;
      });
    }
  }

  Future<void> _saveBookToFirestore(book_model.MetaData book) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('opened_books').add({
        'userId': user.uid,
        'title': book.title,
        'authors': book.authors?.join(', ') ?? 'Unknown',
        'published_date': book. publishedDate?? 'Unknown',
        'genre': book.categories?.join(', ') ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving book to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Details"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : book == null
          ? const Center(child: Text("No data found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book!.image?.isNotEmpty == true)
              Center(
                child: Image.network(
                  book!.image!,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Column(
                    children: const [
                      Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      Text("Image not available"),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              book!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "by ${book!.authors?.join(', ') ?? 'Unknown'}",
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            Text("Publisher: ${book!. publishedDate ?? 'Unknown'}"),
            Text("Genre: ${book!.categories?.join(', ') ?? 'Unknown'}"),
            Text("published_date: ${book!.publishedDate ?? 'Unknown'}"),
            const SizedBox(height: 16),
            const Text(
              "Description:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(book!.description ?? 'No description available.'),
            const SizedBox(height: 24),
            if (book!.pdfPath != null && book!.pdfPath!.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          pdfPath: book!.pdfPath!,
                          pdfName: book!.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Read Now"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: const Color(0xFF3B82F6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
