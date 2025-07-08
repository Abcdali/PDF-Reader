import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:epub_view/epub_view.dart';
import 'package:path/path.dart' as path;

class  PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String pdfName;

  const  PdfViewerScreen({
    Key? key,
    required this.pdfPath,
    required this.pdfName,
  }) : super(key: key);

  @override
  State< PdfViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State< PdfViewerScreen> {
  late String extension;
  int totalPage = 0;
  int currentPage = 0;
  EpubController? _epubController;

  @override
  void initState() {
    super.initState();
    extension = path.extension(widget.pdfPath).toLowerCase();

    if (extension == '.epub') {
      _epubController = EpubController(
        document: EpubReader.readBook(File(widget.pdfPath).readAsBytesSync()),
      );
    }
  }

  @override
  void dispose() {
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(widget.pdfPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        backgroundColor: Colors.blueAccent,
      ),
      body: Builder(
        builder: (context) {
          if (extension == '.pdf') {
            return PDFView(
              filePath: widget.pdfPath,
              pageFling: false,
              autoSpacing: false,
              onRender: (pages) {
                setState(() {
                  totalPage = pages ?? 0;
                });
              },
              onPageChanged: (page, total) {
                setState(() {
                  currentPage = page ?? 0;
                });
              },
            );
          } else if (extension == '.epub') {
            if (_epubController == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return EpubView(controller: _epubController!);
          } else {
            return const Center(child: Text("Unsupported file format"));
          }
        },
      ),
    );
  }
}
