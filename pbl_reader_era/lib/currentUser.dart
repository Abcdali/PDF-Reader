import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pbl_reader_era/Books.dart';
import 'package:pbl_reader_era/Login.dart';
class currentUser extends StatefulWidget {
  const currentUser({super.key});

  @override
  State<currentUser> createState() => _currentUserState();
}

class _currentUserState extends State<currentUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot){
            if(snapshot.hasData){
              return Book_documents();
            }
            else{
              return Login();
            }
          }
      ),
    );
  }
}
