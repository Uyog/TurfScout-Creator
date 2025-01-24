import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:turf_scout_creator/components/token_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = 'Username'; // Default name
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the widget initializes
  }

  Future<void> fetchUserData() async {
    String? token = await TokenManager.instance.retrieveToken(); // Retrieve token securely

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user'), // Replace with your actual API URL
        headers: {
          'Authorization': 'Bearer $token', // Use the retrieved token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name']; // Update userName with the fetched name
          isLoading = false; // Set loading to false after fetching data
        });
      } else {
        setState(() {
          isLoading = false; // Set loading to false even on error
        });
        print('Failed to load user data');
      }
    } else {
      print('No token found'); // Handle case where no token is found
      setState(() => isLoading = false);
    }
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
          onPressed: () {}, // Add functionality here
        ),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
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
                            'Welcome $userName!', // Display the user's name here
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sports categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryButton('Football'),
                        _buildCategoryButton('Basketball'),
                        _buildCategoryButton('Paddle'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Featured Arena
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arena One',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.location_on, color: Colors.red, size: 16),
                                  SizedBox(width: 4),
                                  Text('Langata'),
                                ],
                              ),
                              Row(
                                children: const [
                                  Text('Kshs 2500', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.star, color: Colors.yellow, size: 16),
                                  SizedBox(width: 4),
                                  Text('4.9'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Events Section
                    const Text(
                      'EVENTS',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      // Placeholder for event content
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryButton(String title) {
    return ElevatedButton(
      onPressed: () {}, // Add functionality here
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
