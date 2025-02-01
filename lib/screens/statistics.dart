import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/token_manager.dart';

class Statistics extends StatefulWidget {
  final int turfId;

  const Statistics({super.key, required this.turfId});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  Map<String, dynamic>? statistics;
  bool isLoading = true;
  String? errorMessage;
  String turfName = '';

  @override
  void initState() {
    super.initState();
    fetchTurfDetails();
  }

  Future<void> fetchTurfDetails() async {
    await Future.wait([fetchTurfName(), fetchStatistics()]);
  }

  Future<void> fetchTurfName() async {
    try {
      final headers = await _buildHeaders();

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/turfs/${widget.turfId}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          turfName = data['name'] ?? 'Turf Statistics';
        });
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
      } else {
        throw Exception('Failed to load turf name');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading turf name: $e";
      });
    }
  }

  Future<void> fetchStatistics() async {
    try {
      final headers = await _buildHeaders();

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/turfs/${widget.turfId}/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          statistics = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading statistics: $e";
        isLoading = false;
      });
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    String? token = await TokenManager.instance.retrieveToken();

    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    return {'Authorization': 'Bearer $token'};
  }

  Future<void> _handleUnauthorized() async {
    await TokenManager.instance.deleteToken();
    setState(() {
      errorMessage = "Unauthorized access. Please log in again.";
      isLoading = false;
    });
  }

  Widget buildStatisticsCard(String title, Map<String, dynamic> data) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: TextStyle(fontSize: 16)),
                    Text('\$${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(turfName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : statistics != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('General Statistics',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10),
                                    Text(
                                        'Bookings: ${statistics!['bookings']}',
                                        style: TextStyle(fontSize: 16)),
                                    Text(
                                        'Revenue: \$${statistics!['revenue'].toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16)),
                                    Text(
                                        'Average Rating: ${statistics!['average_rating'].toStringAsFixed(1)}',
                                        style: TextStyle(fontSize: 16)),
                                    Text(
                                        'Total Hours Booked: ${statistics!['total_hours_booked']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildStatisticsCard(
                              "Daily Revenue",
                              Map<String, dynamic>.from(
                                  statistics!['daily_revenue']),
                            ),
                            buildStatisticsCard(
                              "Weekly Revenue",
                              Map<String, dynamic>.from(
                                  statistics!['weekly_revenue']),
                            ),
                            buildStatisticsCard(
                              "Monthly Revenue",
                              Map<String, dynamic>.from(
                                  statistics!['monthly_revenue']),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: Text('No statistics available')),
    );
  }
}
