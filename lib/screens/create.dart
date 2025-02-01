import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/text_field.dart';
import 'dart:convert';
import 'package:turf_scout_creator/components/token_manager.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hourlyPriceController = TextEditingController();
  final TextEditingController _numberOfPitchesController = TextEditingController();

  final List<Uint8List> _webImages = []; // List to store selected images
  bool _isSubmitting = false;

  // Pick image(s) and add them to the list
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

  // Display all selected images as previews
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
                width: 100, // Adjust the size as needed
                height: 100,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      );
    }
  }

  // Handle form submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_webImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Retrieve the stored token
      final String? token = await TokenManager.instance.retrieveToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final uri = Uri.parse('http://127.0.0.1:8000/api/turf');
      final request = http.MultipartRequest('POST', uri);

      // Add headers, including the token for authorization
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
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
          filename: 'upload$i.png', // Unique filename for each image
        ));
      }

      // Send the request
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turf created successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _webImages.clear(); // Clear selected images
          _isSubmitting = false;
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
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Turf'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyButton(
                  text: 'Pick Image(s)',
                  onTap: _pickImage,
                ),
                const SizedBox(height: 16),
                _buildImagePreview(), // Show all selected images here
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
                  text: _isSubmitting ? 'Submitting...' : 'Submit',
                  onTap: _isSubmitting ? null : _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
