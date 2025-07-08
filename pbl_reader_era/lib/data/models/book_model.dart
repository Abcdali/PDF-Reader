import 'dart:convert';

BookResponse bookResponseFromJson(String str) =>
    BookResponse.fromJson(json.decode(str));

class BookResponse {
  List<BookItem> items;

  BookResponse({required this.items});

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    return BookResponse(
      items: json["items"] == null
          ? []
          : List<BookItem>.from(
          json["items"].map((x) => BookItem.fromJson(x))),
    );
  }
}

class BookItem {
  MetaData volumeInfo;

  BookItem({required this.volumeInfo});

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      volumeInfo: MetaData.fromJson(json["volumeInfo"]),
    );
  }
}

class MetaData {
  String title;
  List<String>? authors;
  String? description;
  List<String>? categories;
  String? publishedDate;
  String? image;
  String? pdfPath;

  MetaData({
    required this.title,
    this.authors,
    this.description,
    this.categories,
    this.publishedDate,
    this.image,
    this.pdfPath,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      title: json["title"] ?? "Untitled",
      authors: json["authors"] != null
          ? List<String>.from(json["authors"])
          : null,
      description: json["description"],
      categories: json["categories"] != null
          ? List<String>.from(json["categories"])
          : null,
      publishedDate: json["publishedDate"],
      image: json["imageLinks"] != null ? json["imageLinks"]["thumbnail"] : null,
    );
  }

  factory MetaData.fromMap(Map<String, dynamic> map) {
    return MetaData(
      title: map['title'] ?? 'Untitled',
      authors: map['author'] != null
          ? map['author'].toString().split(',').map((s) => s.trim()).toList()
          : null,
      description: map['description'],
      categories: map['genre'] != null
          ? map['genre'].toString().split(',').map((s) => s.trim()).toList()
          : null,
      publishedDate: map['published_date'],
      image: map['image'],
      pdfPath: map['pdf_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': authors?.join(', '),
      'description': description,
      'genre': categories?.join(', '),
      'published_date': publishedDate,
      'image': image,
      'pdf_path': pdfPath,
    };
  }
}
