import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pbl_reader_era/otpPage.dart';
import 'package:get/get.dart';

class phone extends StatefulWidget {
  const phone({super.key});
  State<phone> createState() => _phoneState();
}

class _phoneState extends State<phone> {
  TextEditingController phonenumber = TextEditingController();

  sendcode() async {
    if (phonenumber.text.isEmpty || phonenumber.text.length < 10) {
      Get.snackbar(
        "Error",
        "Please enter a valid phone number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+92' + phonenumber.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print("verificationFailed error: ${e.code} - ${e.message}");
          Get.snackbar("Error", e.message ?? "Verification failed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            borderRadius: 8,
            duration: Duration(seconds: 3),
          );
        },
        codeSent: (String vid, int? token) {
          Get.to(otpPage(vid: vid, number: phonenumber.text));
        },
        codeAutoRetrievalTimeout: (vid) {},
      );
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      Get.snackbar("Firebase Error", e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        duration: Duration(seconds: 3), );



    } catch (e) {
      print("General Exception: ${e.toString()}");
      Get.snackbar("General Exception", e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Image.asset("assets/images/enterotp.png"),
          Center(
            child: Text(
              "Your Phone !",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
            child: Text("we will send you a one time password on this mobile number",style: TextStyle(fontSize: 18),),
          ),
          SizedBox(height: 20),
          phonetext(),
          SizedBox(height: 50),
          button(),
        ],
      ),
    );
  }

  Widget button() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          sendcode();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(90, 208, 248, 1.0),
          padding: const EdgeInsets.all(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 90),
          child: Text(
            "Receive OTP",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget phonetext() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        controller: phonenumber,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefix: Text("+92 - "),
          prefixIcon: Icon(Icons.phone),
          labelText: "Enter Phone Number",
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
