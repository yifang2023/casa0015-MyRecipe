import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as: ' + user.email!),
            MaterialButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                color: Color.fromARGB(197, 143, 180, 193),
                child: const Text('Sign out')),
          ],
        ),
      ),
    );
  }
}
