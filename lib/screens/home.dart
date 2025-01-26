import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/navigation_bar.dart';
import 'dart:convert';
import 'package:turf_scout_creator/components/token_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = 'Username';
  bool isLoading = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String? token = await TokenManager.instance.retrieveToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Failed to load user data');
      }
    } else {
      print('No token found');
      setState(() => isLoading = false);
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentTab = index;
    });
    // Handle navigation logic here based on the index
    print("Selected tab: $index");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TURFSCOUT'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentTab,
              children: [
                _buildHomeContent(),
                const Center(child: Text("Search Screen")),
                const Center(child: Text("Events Screen")),
                const Center(child: Text("Profile Screen")),
              ],
            ),
      bottomNavigationBar: CurvedNavigationBarWidget(onTap: _onNavItemTapped),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '(Lottie Animation)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Welcome $userName!',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('Football'),
                _buildCategoryButton('Basketball'),
                _buildCategoryButton('Paddle'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
