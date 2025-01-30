import 'package:flutter/material.dart';
import 'package:turf_scout_creator/components/navigation_bar.dart';
import 'package:turf_scout_creator/screens/create.dart';
import 'package:turf_scout_creator/screens/home.dart';
import 'package:turf_scout_creator/screens/turfs.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const Center(child: Text("Search Screen")), 
    const Create(), 
    const Turfs(), 
    const Center(child: Text("Profile Screen")), 
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CurvedNavigationBarWidget(onTap: _onNavItemTapped),
    );
  }
}
