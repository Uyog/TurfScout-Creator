import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:turf_scout_creator/components/alert_dialogue.dart';
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/text_field.dart'; // Import your custom dialog

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  // Function to send OTP
  Future<void> sendOtp() async {
    final String apiUrl = "http://127.0.0.1:8000/api/send-otp"; // Replace with your backend URL

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text}),
      );

      if (response.statusCode == 200) {
        // Success: Show the custom dialog
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            lottiePath: 'assets/images/Animation - 1735402589418.json', // Replace with your success animation path
            title: "Success",
            message: "OTP sent to your email.",
            onButtonPressed: () {
              Navigator.pushNamed(context, '/otp', arguments: {'email': emailController.text}); // Close the dialog
            },
          ),
        );
      } else {
        // Error: Show the custom dialog
        final responseBody = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            lottiePath: 'assets/images/Animation - 1735403141081.json', // Replace with your error animation path
            title: "Error",
            message: responseBody['message'] ?? "Something went wrong.",
            onButtonPressed: () {
              Navigator.pop(context); // Close the dialog
            },
          ),
        );
      }
    } catch (error) {
      // Handle network errors
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          lottiePath: 'assets/images/Animation - 1735403141081.json', // Replace with your error animation path
          title: "Error",
          message: "Failed to send OTP. Please try again.",
          onButtonPressed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ),
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
                  'assets/images/Animation - 1737647300816.json',
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Forgot Password Title
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: screenHeight * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Subtitle
              Text(
                "It's okay it happens. Please enter your email",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Custom Email TextField
              CustomTextField(
                controller: emailController,
                labelText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Custom Submit Button
              MyButton(
                text: isLoading ? 'Sending...' : 'Submit',
                onTap: () {
                  if (!isLoading) {
                    sendOtp();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
