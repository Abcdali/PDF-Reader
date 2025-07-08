import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'Login.dart';
import 'SignUp.dart';
import 'Books.dart';
import 'Diamond.dart';
import 'readera.dart';
import 'AdminDashboard.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final isLoggedIn = snapshot.data ?? false;
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: isLoggedIn ? "Books" : "Login",
            routes: {
              "Login": (context) => Login(),
              "SignUp": (context) => SignUp(),
              "Books": (context) => Book_documents(),
              "Diamond": (context) => Diamond(),
              "readera": (context) => readera(),
              "AdminDashboard": (context) => AdminDashboard(),
            },
          );
        }
      },
    );
  }
}
