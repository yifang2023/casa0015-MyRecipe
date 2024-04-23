import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// navigation bar
class MyBottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GNav(
      color: Colors.grey[400],
      activeColor: Colors.grey.shade800, // setting the active color
      tabActiveBorder:
          Border.all(color: Colors.white), // setting the active border
      tabBackgroundColor: Color(0xFFE9EFF9), // setting the tab background color
      mainAxisAlignment: MainAxisAlignment.center,
      tabBorderRadius: 16,
      onTabChange: (value) => onTabChange!(value),
      tabs: [
        GButton(
          icon: Icons.home,
          text: 'Recipe',
        ),
        GButton(
          icon: Icons.settings,
          text: 'Settings',
        ),
      ],
    ));
  }
}
