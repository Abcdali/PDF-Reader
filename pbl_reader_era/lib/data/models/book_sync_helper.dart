import '../models/book_model.dart';
import '../models/google_book_api.dart';
import '../models/book_database.dart';

Future<void> saveBookFromApi(String title) async {
  MetaData? book = await GoogleBookAPI.fetchBookByTitle(title);

  if (book != null) {
    await inserting_book(book);
    print("Inserted into SQLite!");
    await checkInsertedBooks(); // optional for debug
  } else {
    print("Book not found from API.");
  }
}
