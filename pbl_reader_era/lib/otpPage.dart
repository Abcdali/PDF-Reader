import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pbl_reader_era/currentUser.dart';
import 'package:pinput/pinput.dart';
class otpPage extends StatefulWidget {
  final String vid;
  final String number;

  const otpPage({super.key, required this.vid, required this.number});

  @override
  State<otpPage> createState() => _otpPageState();
}

class _otpPageState extends State<otpPage> {
  var code = "";

  SignIn() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.vid,
      smsCode: code,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        Get.offAll(currentUser()); // Navigate to Home Page
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account created successfully"),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );

    }
    on FirebaseAuthException catch (e) {
      Get.snackbar("Error Occurred", e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.message}"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Get.snackbar("Error Occurred", e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          children: [
            Image.asset("assets/images/OTP.png", height: 330, width: 330),
            Center(
              child: Text(
                "OTP verification",
                style: TextStyle(fontSize: 30,fontStyle: FontStyle.italic,),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 6),
              child: Text("Enter OTP sent to +92 - ${widget.number}",style: TextStyle(fontSize: 18),),
            ),
            SizedBox(height: 20),
            textcode(),
            SizedBox(height: 80),
            button(),
          ],
        ),
      ),
    );
  }

  Widget button() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          SignIn();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(140, 178, 241, 1),
          padding: const EdgeInsets.all(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: Text(
            "Verify & Proceed",
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

  Widget textcode() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Pinput(
          length: 6,
          showCursor: true,
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
          onChanged: (value) {
            setState(() {
              code = value;
            });
          },
        ),
      ),
    );
  }

}
