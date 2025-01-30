import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/text_field.dart';
import 'dart:convert';
import 'package:turf_scout_creator/components/token_manager.dart';

class UpdateTurf extends StatefulWidget {
  final int turfId;
  final String currentName;
  final String currentPrice;
  final String currentLocation;
  final String currentDescription;
  final String currentNumberOfPitches;

  const UpdateTurf({
    super.key,
    required this.turfId,
    required this.currentName,
    required this.currentPrice,
    required this.currentLocation,
    required this.currentDescription,
    required this.currentNumberOfPitches,
  });

  @override
  State<UpdateTurf> createState() => _UpdateTurfState();
}

class _UpdateTurfState extends State<UpdateTurf> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _hourlyPriceController;
  late TextEditingController _numberOfPitchesController;

  List<Uint8List> _webImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _locationController = TextEditingController(text: widget.currentLocation);
    _descriptionController = TextEditingController(text: widget.currentDescription);
    _hourlyPriceController = TextEditingController(text: widget.currentPrice);
    _numberOfPitchesController = TextEditingController(text: widget.currentNumberOfPitches);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();

      setState(() {
        _webImages.add(fileBytes);
      });
    }
  }

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

  Future<void> _updateTurf() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String? token = await TokenManager.instance.retrieveToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final uri = Uri.parse('http://127.0.0.1:8000/api/turf/${widget.turfId}');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['_method'] = 'PUT';
      request.fields['name'] = _nameController.text;
      request.fields['location'] = _locationController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price_per_hour'] = _hourlyPriceController.text;
      request.fields['number_of_pitches'] = _numberOfPitchesController.text;

      for (int i = 0; i < _webImages.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'images[]',
          _webImages[i],
          filename: 'update$i.png',
        ));
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turf updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = jsonDecode(responseData.body)['error'] ?? 'Failed to update turf';
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
        title: const Text('Update Turf'),
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
                  text: _isSubmitting ? 'Updating...' : 'Update',
                  onTap: _isSubmitting ? null : _updateTurf,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
