import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pbl_reader_era/SignUp.dart';
import 'package:pbl_reader_era/phone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final String adminEmail = "admin@example.com";
  final String adminPassword = "admin123";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> signinAdmin(BuildContext context, String email, String password) async {
    try {
      if (email == adminEmail && password == adminPassword) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome Admin!"), backgroundColor: Colors.green.shade700),
        );
        Navigator.pushReplacementNamed(context, "AdminDashboard");
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged in successfully"), backgroundColor: Colors.green.shade700),
      );
      Navigator.pushReplacementNamed(context, "Books");
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red.shade700),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred"), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> signin(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in successfully"), backgroundColor: Colors.green.shade700),
      );
      Navigator.pushReplacementNamed(context, "Books");
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red.shade700),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred"), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> log_in() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in with Google"), backgroundColor: Colors.green.shade700),
      );
      Navigator.pushReplacementNamed(context, "Books");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed"), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      contentPadding: EdgeInsets.symmetric(vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
                      ),
                      child: Image.asset("assets/images/E-book.png", height: 100, width: 100),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Welcome Back", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Sign in to continue", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecoration(hint: "Email", icon: Icons.email_outlined),
                    validator: (value) => value!.isEmpty ? "Please enter your email" : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: inputDecoration(
                      hint: "Password",
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.blue.shade700),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Please enter your password" : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final email = emailController.text.trim();
                        final password = passwordController.text;
                        if (email == adminEmail && password == adminPassword) {
                          signinAdmin(context, email, password);
                        } else {
                          signin(context, email, password);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4ADE80),
                      padding: EdgeInsets.symmetric(horizontal: 130, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("LOG IN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SignUp()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(horizontal: 130, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("SIGN UP", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white54)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("OR", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: Colors.white54)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: log_in,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              Image.asset("assets/images/google-removebg-preview.png", height: 20, width: 20),
                              SizedBox(width: 10),
                              Text("Google", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => phone()));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              Image.asset("assets/images/Mobile.png", height: 24),
                              SizedBox(width: 10),
                              Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
