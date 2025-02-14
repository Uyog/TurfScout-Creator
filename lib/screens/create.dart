import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/text_field.dart';
import 'package:turf_scout_creator/components/token_manager.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  // Toggle between turf and event forms.
  bool _isTurfSelected = true;

  // FORM KEYS
  final GlobalKey<FormState> _turfFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _eventFormKey = GlobalKey<FormState>();

  // Controllers for Turf Creation Form (with image upload)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hourlyPriceController = TextEditingController();
  final TextEditingController _numberOfPitchesController = TextEditingController();
  final List<Uint8List> _webImages = []; // List to store selected images
  bool _isTurfSubmitting = false;

  // Controllers for Event Creation Form
  final TextEditingController _eventTurfIdController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventPriceController = TextEditingController();
  final TextEditingController _eventStartTimeController = TextEditingController();
  final TextEditingController _eventEndTimeController = TextEditingController();
  bool _isEventSubmitting = false;

  // ----- Turf Creation Methods -----

  // Pick image(s) for turf
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();
      setState(() {
        _webImages.add(fileBytes); // Add new image to the list
      });
    }
  }

  // Display turf image previews
  Widget _buildImagePreview() {
    if (_webImages.isEmpty) {
      return const Text('No images selected');
    } else {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _webImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.memory(
                _webImages[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      );
    }
  }

  // Submit Turf Creation Form
  Future<void> _submitTurfForm() async {
    if (!_turfFormKey.currentState!.validate()) return;
    if (_webImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isTurfSubmitting = true;
    });

    try {
      final String? token = await TokenManager.instance.retrieveToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final uri = Uri.parse('http://127.0.0.1:8000/api/turf');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields for turf creation
      request.fields['name'] = _nameController.text;
      request.fields['location'] = _locationController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price_per_hour'] = _hourlyPriceController.text;
      request.fields['number_of_pitches'] = _numberOfPitchesController.text;

      // Add images
      for (int i = 0; i < _webImages.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'images[]', // Using an array field name for images
          _webImages[i],
          filename: 'upload$i.png',
        ));
      }

      // Send the request
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turf created successfully!')),
        );
        _turfFormKey.currentState!.reset();
        setState(() {
          _webImages.clear();
        });
      } else {
        final errorMessage = jsonDecode(responseData.body)['error'] ??
            'Failed to create turf: ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isTurfSubmitting = false;
      });
    }
  }

  // ----- Event Creation Methods -----

  // Submit Event Creation Form
  Future<void> _submitEventForm() async {
    if (!_eventFormKey.currentState!.validate()) return;

    setState(() {
      _isEventSubmitting = true;
    });

    try {
      final String? token = await TokenManager.instance.retrieveToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final String apiUrl = "http://127.0.0.1:8000/api/events";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "turf_id": _eventTurfIdController.text,
          "description": _eventDescriptionController.text,
          "price": double.parse(_eventPriceController.text),
          "start_time": _eventStartTimeController.text,
          "end_time": _eventEndTimeController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event created successfully!")),
        );
        _eventFormKey.currentState!.reset();
      } else {
        final errorMsg = jsonDecode(response.body)['error'] ?? 
          'Failed to create event: ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isEventSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    // Turf controllers
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _hourlyPriceController.dispose();
    _numberOfPitchesController.dispose();
    // Event controllers
    _eventTurfIdController.dispose();
    _eventDescriptionController.dispose();
    _eventPriceController.dispose();
    _eventStartTimeController.dispose();
    _eventEndTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row with two tickets (cards) for "Create Turf" and "Create Event"
            Row(
              children: [
                // Create Turf ticket
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTurfSelected = true;
                      });
                    },
                    child: Card(
                      color: _isTurfSelected ? Colors.blue : Colors.grey,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 30),
                            SizedBox(height: 8),
                            Text(
                              "Create Turf",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Create Event ticket
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTurfSelected = false;
                      });
                    },
                    child: Card(
                      color: !_isTurfSelected ? Colors.green : Colors.grey,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.event, color: Colors.white, size: 30),
                            SizedBox(height: 8),
                            Text(
                              "Create Event",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Conditional rendering of forms based on selection
            _isTurfSelected
                ? Form(
                    key: _turfFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyButton(
                          text: 'Pick Image(s)',
                          onTap: _pickImage,
                        ),
                        const SizedBox(height: 16),
                        _buildImagePreview(),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Name',
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _locationController,
                          labelText: 'Location',
                          prefixIcon: Icons.location_on,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          prefixIcon: Icons.description,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _hourlyPriceController,
                                labelText: 'Price',
                                prefixIcon: Icons.monetization_on,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _numberOfPitchesController,
                                labelText: 'Pitches',
                                prefixIcon: Icons.sports_soccer,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        MyButton(
                          text: _isTurfSubmitting ? 'Submitting...' : 'Submit',
                          onTap: _isTurfSubmitting ? null : _submitTurfForm,
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _eventFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextField(
                          controller: _eventTurfIdController,
                          labelText: 'Turf ID',
                          prefixIcon: Icons.location_on,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _eventDescriptionController,
                          labelText: 'Description',
                          prefixIcon: Icons.description,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _eventPriceController,
                          labelText: 'Price',
                          prefixIcon: Icons.monetization_on,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _eventStartTimeController,
                          labelText: 'Start Time',
                          prefixIcon: Icons.punch_clock_sharp,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _eventEndTimeController,
                          labelText: 'End Time',
                          prefixIcon: Icons.punch_clock_sharp,
                        ),
                        const SizedBox(height: 16),
                        MyButton(
                          text: _isEventSubmitting ? 'Submitting...' : 'Submit',
                          onTap: _isEventSubmitting ? null : _submitEventForm,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
