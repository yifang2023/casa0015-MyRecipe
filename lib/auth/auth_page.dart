import 'dart:math';

import 'package:MyRecipe/pages/login_page.dart';
import 'package:MyRecipe/pages/signup_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // show login page
  bool showLoginpage = true;

  void toggleScreens() {
    setState(() {
      showLoginpage = !showLoginpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginpage) {
      return LoginPage(showSignUpPage: toggleScreens);
    } else {
      return SignUpPage(showLoginPage: toggleScreens);
    }
  }
}
