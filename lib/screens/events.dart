import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/token_manager.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  State<Events> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<Events> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the event form fields
  final TextEditingController _turfIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final String apiUrl = "http://127.0.0.1:8000/api/events";

    try {
      final String? token = await TokenManager.instance.retrieveToken();
      if (token == null) throw Exception("No token found. Please log in.");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "turf_id": _turfIdController.text,
          "description": _descriptionController.text,
          "price": double.parse(_priceController.text),
          "start_time": _startTimeController.text,
          "end_time": _endTimeController.text,
          // Optionally include an "event_photo" field if needed.
        }),
      );

      if (response.statusCode == 201) {
        // Event created successfully.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event created successfully!")),
        );
        // Optionally clear the form fields.
        _turfIdController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
      } else {
        // Print out the error response from the server.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create event: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _turfIdController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Turf ID Field
              TextFormField(
                controller: _turfIdController,
                decoration: const InputDecoration(
                  labelText: "Turf ID",
                  hintText: "Enter the Turf ID where the event is hosted",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Turf ID";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Enter a description for the event",
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                  hintText: "Enter the team participation price",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a price";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Start Time Field
              TextFormField(
                controller: _startTimeController,
                decoration: const InputDecoration(
                  labelText: "Start Time",
                  hintText: "YYYY-MM-DD HH:MM:SS",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter start time";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // End Time Field
              TextFormField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: "End Time",
                  hintText: "YYYY-MM-DD HH:MM:SS",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter end time";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Create Event Button
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createEvent,
                      child: const Text("Create Event"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
