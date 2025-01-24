import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/text_field.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  late String email; // Email passed from arguments

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    email = arguments?['email'] ?? ''; // Retrieve email from arguments
  }

  // Function to reset the password
  Future<void> resetPassword() async {
    final String apiUrl = "http://127.0.0.1:8000/api/reset-password";

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Success: Navigate to login screen or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully.")),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        // Handle errors
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? "Failed to reset password.")),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                height: screenHeight * 0.25,
                child: Lottie.asset(
                  'assets/images/Animation - 1737651810989.json', // Replace with your animation
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Reset Password Title
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: screenHeight * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Subtitle
              Text(
                'Set your new password below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Password Field
              CustomTextField(
                controller: passwordController,
                labelText: "New Password",
                prefixIcon: Icons.lock,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Confirm Password Field
              CustomTextField(
                controller: confirmPasswordController,
                labelText: "Confirm Password",
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Submit Button
              MyButton(
                text: isLoading ? 'Resetting...' : 'Reset Password',
                onTap: isLoading ? null : resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
