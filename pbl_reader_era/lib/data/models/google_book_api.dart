import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_model.dart';

class GoogleBookAPI {
  static const String _baseUrl = "https://www.googleapis.com/books/v1/volumes";

  static Future<MetaData?> fetchBookByTitle(String title) async {
    try {
      final url = Uri.parse("$_baseUrl?q=intitle:${Uri.encodeComponent(title)}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data["items"] != null && data["items"].isNotEmpty) {
          final volumeInfo = data["items"][0]["volumeInfo"];

          print("Fetched Book: ${volumeInfo["title"]}");

          return MetaData.fromJson(volumeInfo);
        } else {
          print("No book items found for title: $title");
        }
      } else {
        print("Google API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception while fetching book: $e");
    }

    return null;
  }
}
