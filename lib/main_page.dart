import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MyRecipe/login_page.dart';
import 'package:MyRecipe/home_page.dart';

// mian page
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // check if the user is signed in or not
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
