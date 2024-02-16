import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //初始化Flutter应用程序绑定
  await Firebase.initializeApp();
  // await appCheck();
  runApp(const MyApp());
}

// ///
// /// https://firebase.google.com/docs/app-check/flutter/default-providers?authuser=0&hl=zh
// ///
// Future<void> appCheck() async {
//   return await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.debug,
//     webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
//     appleProvider: AppleProvider.appAttest,
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Container(
        alignment: Alignment.center, //container内部的内容居中
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue, // container的背景颜色
        ),
        child: const Text(
          'Hello Flutter',
          textDirection: TextDirection.ltr,
          style: TextStyle(
              fontSize: 32.0, color: Color.fromARGB(255, 176, 22, 22)),
        ),
      ),
    );
  }
}
