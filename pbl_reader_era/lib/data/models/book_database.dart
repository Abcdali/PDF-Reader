import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'book_model.dart';

Future<Database> create_book_DB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, "Books.db");
  print("Database path: $path");

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          author TEXT,
          description TEXT,
          genre TEXT,
          published_date TEXT,
          image TEXT,
          UNIQUE(title, author)
        )
      ''');
    },
  );
}

Future<void> inserting_book(MetaData book) async {
  print("Inserting book into SQLite: ${book.title}");
  final db = await create_book_DB();
  await db.insert(
    'books',
    {
      'title': book.title,
      'author': book.authors?.join(', ') ?? 'N/A',
      'description': book.description ?? 'N/A',
      'genre': book.categories?.join(', ') ?? 'N/A',
      'published_date': book.publishedDate ?? 'N/A',
      'image': book.image ?? '',
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
  print("Inserted successfully.");
}


Future<void> checkInsertedBooks() async {
  final db = await create_book_DB();
  final books = await db.query('books');

  if (books.isEmpty) {
    print("No data found.");
  } else {
    print("Data found:");
    for (var b in books) {
      print("${b['title']} by ${b['author']}");
    }
  }
}
