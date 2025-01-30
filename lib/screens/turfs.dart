import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/token_manager.dart';
import 'dart:convert';
import 'update.dart'; // Import update page

class Turfs extends StatefulWidget {
  const Turfs({super.key});

  @override
  State<Turfs> createState() => _TurfsState();
}

class _TurfsState extends State<Turfs> {
  List<Map<String, dynamic>> turfs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTurfs();
  }

  // Fetch turfs from API
  Future<void> fetchTurfs() async {
    final String apiUrl = "http://127.0.0.1:8000/api/turf";

    try {
      // Retrieve token securely
      final String? token = await TokenManager.instance.retrieveToken();

      if (token == null) {
        throw Exception("No token found. Please log in again.");
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body); // Decode as Map
        List<dynamic> turfsData = data['data']; // Assuming the list is under 'data'

        setState(() {
          turfs = List<Map<String, dynamic>>.from(turfsData);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load turfs");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Delete turf
  Future<void> deleteTurf(int id) async {
    final String apiUrl = "http://127.0.0.1:8000/api/turf/$id";

    try {
      // Retrieve token securely
      final String? token = await TokenManager.instance.retrieveToken();

      if (token == null) {
        throw Exception("No token found. Please log in again.");
      }

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          turfs.removeWhere((turf) => turf['id'] == id);
        });
      } else {
        throw Exception("Failed to delete turf");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TURFS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: turfs.length,
                itemBuilder: (context, index) {
                  final turf = turfs[index];

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                turf['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Kshs ${turf['price_per_hour']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateTurf(turfId: turf['id']),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteTurf(turf['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
