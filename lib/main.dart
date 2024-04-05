import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:MyRecipe/auth/main_page.dart'; //第二次commit
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //初始化Flutter应用程序绑定
  await Firebase.initializeApp();
  await appCheck();
  runApp(const MyApp());
}

///
/// https://firebase.google.com/docs/app-check/flutter/default-providers?authuser=0&hl=zh
///
Future<void> appCheck() async {
  return await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    appleProvider: AppleProvider.appAttest,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFE9EFF9),
      ),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
