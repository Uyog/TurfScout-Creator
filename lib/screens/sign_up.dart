import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/alert_dialogue.dart';
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/login_sign_up.dart';
import 'package:turf_scout_creator/components/text_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Controllers for the text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // For button state
  String _errorMessage = ""; // For displaying errors

  // Function to handle user registration
  Future<void> registerUser() async {
    final String apiUrl = 'http://127.0.0.1:8000/api/register-app';

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
          'mobile': phoneController.text,
        }),
      );

      if (response.statusCode == 201) {
        json.decode(response.body);

        // Show success dialog and navigate to login
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            lottiePath: 'assets/images/Animation - 1735402589418.json',
            title: "Success",
            message: "Account created successfully!",
            buttonText: "Login",
            onButtonPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        );
      } else {
        final errorData = json.decode(response.body);

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            lottiePath: 'assets/images/Animation - 1735403141081.json',
            title: "Error",
            message: errorData['message'] ?? "Registration failed.",
            buttonText: "Retry",
            onButtonPressed: () {
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred. Please try again.";
      });

      // Show generic error dialog
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          lottiePath: 'assets/images/Animation - 1735403141081.json',
          title: "Error",
          message: _errorMessage,
          buttonText: "Retry",
          onButtonPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Lottie Animation
                SizedBox(
                  height: screenHeight * 0.25,
                  width: screenWidth,
                  child: Lottie.asset(
                    'assets/images/Animation - 1735327545185.json',
                    repeat: false,
                  ),
                ),
                // Title
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Form Fields
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: usernameController,
                        labelText: 'Username',
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: phoneController,
                        labelText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: passwordController,
                        labelText: "Password",
                        prefixIcon: Icons.lock,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: confirmPasswordController,
                        labelText: 'Confirm Password',
                        prefixIcon: Icons.lock,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 20),
                      // Button and Navigation Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyButton(
                            text: _isLoading ? 'Creating...' : 'Create Account',
                            onTap: _isLoading ? null : registerUser,
                          ),
                          const SizedBox(height: 8), // Tight spacing here
                          SignUpNavigationText(
                            questionText: "Already have an account?",
                            actionText: "Login",
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
