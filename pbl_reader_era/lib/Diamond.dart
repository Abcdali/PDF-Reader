import 'package:flutter/material.dart';
class Diamond extends StatelessWidget {
  const Diamond({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF5CA19B),
      backgroundColor: Colors.white,
      body: Center(
        // child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Transform.translate(
                  offset: Offset(-120, 150),
                  child: Icon(
                    Icons.diamond_outlined,
                    size: 60,
                      color: Color(0xFF1E3A8A),
                  ),
                ),
              ),

              Transform.translate(
                offset: Offset(150, -50),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },


                  child: Icon(Icons.close, size: 50, color: Colors.red),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 30, right: 100),
                child: Transform.translate(
                  offset: Offset(90, 30),
                  child: Center(
                    child: Text(
                      "Book reader ReadEra - free app without ads.\n\n\n"
                      "We share your irritation with fullscreen banners and "
                      "intrusive ads, so we've made a reader for books that you can "
                      "use without any risk of getting a heart attack due to some 'Farm' pop-up.\n\n\n"
                      "If you like our work, support us:\n\n"
                      "- Add a link to the application on your website or blog.\n\n"
                      "- Share the app on social networks. ",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        // ),
      ),
    );
  }
}
