import 'package:flutter/material.dart';

class readera extends StatelessWidget {
  const readera({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E3A8A), // Deep blue
                  Color(0xFF3B82F6), // Medium blue
                ],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                "ReadEra\nBook reader pdf, epub, word & pdf viewer",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            "ReadEra-book reader allows reading books for free,\n"
                "offline in PDF, EPUB, Microsoft Word, CHM formats.\n\n"
                "1. No Ads – 100% Free\n"
                "ReadEra offers a completely ad-free reading experience, so you can enjoy your books without any interruptions or distractions.\n\n"
                "2. Supports All Major Formats\n"
                "The app supports a wide range of file formats including PDF, EPUB, MOBI, DOC, TXT, and more, making it easy to read all your favorite books in one place.\n\n"
                "3. Text-to-Speech (TTS)\n"
                "With built-in TTS functionality, ReadEra allows you to listen to your books anytime, turning reading into a hands-free experience.\n\n"
                "4. Smart Library Management\n"
                "ReadEra automatically organizes your books by categories, progress, and file types, helping you manage your digital library with ease.",
            style: TextStyle(fontSize: 16, color: Colors.grey[1000]),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
