import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:turf_scout_creator/components/alert_dialogue.dart';
import 'package:turf_scout_creator/components/button.dart';
import 'package:turf_scout_creator/components/login_sign_up.dart';
import 'package:turf_scout_creator/components/text_field.dart';
import 'package:turf_scout_creator/components/token_manager.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    const String apiUrl =
        "http://127.0.0.1:8000/api/login-creator"; 
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final String token = responseData['data']['token'];
        await TokenManager.instance.storeToken(token); // Store token securely

        final user = responseData['data']['user'];
        final String name = user['name'] ?? 'Unknown';

        _showAlertDialog(
          'assets/images/Animation - 1735402589418.json',
          'Login Successful',
          'Welcome back, $name!',
          () {
            Navigator.pop(context);
            Navigator.pushNamed(
                context, '/home'); // Navigate to home without arguments
          },
        );
      } else {
        final errorMessage = responseData['error'] ??
            responseData['message'] ??
            'An unexpected error occurred.';
        _showAlertDialog(
          'assets/images/Animation - 1735403141081.json',
          'Error',
          errorMessage,
          () => Navigator.pop(context),
        );
      }
    } catch (e) {
      _showAlertDialog(
        'assets/images/Animation - 1735403141081.json',
        'Connection Error',
        'Could not connect to the server. Please try again.',
        () => Navigator.pop(context),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAlertDialog(String lottiePath, String title, String message,
      VoidCallback onButtonPressed) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        lottiePath: lottiePath,
        title: title,
        message: message,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.35,
                width: double.infinity,
                child: Lottie.asset(
                    'assets/images/Animation - 1735327545185.json',
                    repeat: false),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Welcome Back!",
                style: TextStyle(
                    fontSize: screenHeight * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.03),
              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
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
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/password');
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              MyButton(
                text: _isLoading ? "Loading..." : "Login",
                onTap: _isLoading ? null : _login,
              ),
              SizedBox(height: screenHeight * 0.03),
              SignUpNavigationText(
                questionText: "New to TurfScout?",
                actionText: "Sign Up",
                fontSize: screenHeight * 0.02,
                onTap: () => Navigator.pushNamed(context, '/sign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
