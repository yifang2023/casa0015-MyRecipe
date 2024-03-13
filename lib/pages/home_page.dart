import 'package:MyRecipe/components/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:MyRecipe/components/bottom_nav_bar.dart';
import 'package:MyRecipe/pages/recipe_page.dart';
import 'package:MyRecipe/pages/settings_page.dart';
import 'package:MyRecipe/pages/restaurant_page.dart';

// home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

// this selectted index to navigate to the selected bottom bar
  int _selectedIndex = 0;

// navigate to the selected bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// pages to display in the bottom bar
  final List<Widget> _pages = [
    // recipe page
    const RecipePage(),
    // restaurant page
    const RestaurantPage(),
    // settings page
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Signed in as: ' + user.email!),
//             MaterialButton(
//                 onPressed: () {
//                   FirebaseAuth.instance.signOut();
//                 },
//                 color: Color.fromARGB(197, 143, 180, 193),
//                 child: const Text('Sign out')),
//           ],
//         ),
//       ),
//     );
//   }
// }
