import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:turf_scout_creator/components/token_manager.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> turfs = [];
  bool isLoading = true;
  final String apiUrl = 'http://127.0.0.1:8000/api/user';
  final String turfsApiUrl = 'http://127.0.0.1:8000/api/turf';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchTurfs();
  }

  Future<void> fetchUserProfile() async {
    final token = await TokenManager.instance.retrieveToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        user = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  Future<void> fetchTurfs() async {
    final String? token = await TokenManager.instance.retrieveToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse(turfsApiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> turfsData = data['data'];

      setState(() {
        turfs = List<Map<String, dynamic>>.from(turfsData);
        isLoading = false;
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load turfs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text(
          user!['name'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: updateProfilePicture,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user!['profile_picture'] != null
                        ? NetworkImage('http://127.0.0.1:8000/storage/${user!['profile_picture']}')
                        : const AssetImage('assets/images/avatar-gender-neutral-silhouette-vector-600nw-2526512481.webp') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Bookings', (user!['bookings'] ?? 0).toString()),
                      _buildStatColumn('Turfs', turfs.length.toString()),
                      _buildStatColumn('Ratings', (user!['ratings'] ?? 0).toString()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Email: ${user!['email']}', style: const TextStyle(fontSize: 16)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Mobile: ${user!['mobile'] ?? "N/A"}', style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Turfs Created',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: turfs.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      itemCount: turfs.length,
                      itemBuilder: (context, index) {
                        final turf = turfs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.grey[300],
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              turf['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Kshs ${turf['price_per_hour']}', style: const TextStyle(fontSize: 16)),
                          ),
                        );
                      },
                    )
                  : const Text('No turfs created.', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfilePicture() async {
    final token = await TokenManager.instance.retrieveToken();
    if (token == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/profile-picture'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        pickedFile.path,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        fetchUserProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile picture')),
        );
      }
    }
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
