import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          // make the content scrollable
          child: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Our Logo
              Image.asset(
                'asset/MyRecipe_logo.png',
                width: 150,
              ),
              const SizedBox(height: 50),

              // Hello Again!
              Text(
                'Hello Again!',
                style: GoogleFonts.bebasNeue(
                  fontSize: 50,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome back, you\'ve been missed!',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 50),

              // emial textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(199, 230, 42, 0),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    hintText: 'Email',
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // password textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(199, 230, 42, 0),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    hintText: 'Password',
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // sign in button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(197, 134, 211, 219),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // register button
              const Row(
                mainAxisAlignment: MainAxisAlignment.center, // center the text
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    " Sign Up Now",
                    style: TextStyle(
                      color: Color.fromARGB(197, 24, 158, 173),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
