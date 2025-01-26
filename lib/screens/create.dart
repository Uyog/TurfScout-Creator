import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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

  File? _selectedImage;
  Uint8List? _webImage;

  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();

      setState(() {
        if (kIsWeb) {
          _webImage = fileBytes; // For Flutter Web
          _selectedImage = null; // Reset for web compatibility
        } else {
          _selectedImage = File(pickedFile.path);
          _webImage = null; // Reset for non-web platforms
        }
      });
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, height: 150);
    } else if (_selectedImage != null) {
      return Image.file(_selectedImage!, height: 150);
    } else {
      return const Text('No image selected');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
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
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
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

      // Add image file
      if (kIsWeb && _webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _webImage!,
          filename: 'upload.png',
        ));
      } else if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
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
          _selectedImage = null;
          _webImage = null;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a location' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a description'
                      : null,
                ),
                TextFormField(
                  controller: _hourlyPriceController,
                  decoration: const InputDecoration(labelText: 'Hourly Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter an hourly price'
                      : null,
                ),
                TextFormField(
                  controller: _numberOfPitchesController,
                  decoration: const InputDecoration(labelText: 'Number of Pitches'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the number of pitches'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildImagePreview(),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
