import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CurvedNavigationBarWidget extends StatefulWidget {
  final ValueChanged<int> onTap;

  const CurvedNavigationBarWidget({super.key, required this.onTap});

  @override
  State<CurvedNavigationBarWidget> createState() =>
      _CurvedNavigationBarWidgetState();
}

class _CurvedNavigationBarWidgetState extends State<CurvedNavigationBarWidget> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      height: 60.0,
      backgroundColor: Colors.white,
      color: const Color(0xFF76FF03), // Green color for the navbar
      buttonBackgroundColor: const Color(0xFF76FF03), // Same green for the button
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.search, size: 30, color: Colors.white),
        Icon(Icons.add, size: 30, color: Colors.white), // Middle plus icon
        Icon(Icons.event, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
      ],
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });

        // Navigate to "create.dart" when the plus icon is tapped
        if (index == 2) {
          Navigator.pushNamed(context, '/create'); // Ensure you have a route for '/create'
        } else {
          widget.onTap(index); // Trigger callback for other tabs
        }
      },
    );
  }
}
