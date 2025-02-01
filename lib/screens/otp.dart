import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:turf_scout_creator/components/button.dart';

class Otp extends StatefulWidget {
  const Otp({super.key, required String email});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  late String email; // Email will be dynamically set from arguments

  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();
  final TextEditingController otpController5 = TextEditingController();
  final TextEditingController otpController6 = TextEditingController();

  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the email from the arguments
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    email = arguments?['email'] ?? ''; // Default to empty string if null
  }

  Future<void> validateOtp() async {
    String enteredOtp = otpController1.text +
        otpController2.text +
        otpController3.text +
        otpController4.text +
        otpController5.text +
        otpController6.text;

    if (enteredOtp.length == 6) {
      setState(() {
        isLoading = true;
      });

      try {
        // Validate OTP API request
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/validate-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'otp': enteredOtp,
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          // OTP is valid; navigate to Reset Password screen
          Navigator.pushNamed(
            context,
            '/reset',
            arguments: {'email': email, 'otp': enteredOtp},
          );
        } else {
          // Handle invalid OTP or expired OTP
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Invalid OTP')),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // Handle network errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to validate OTP. Please try again.')),
        );
      }
    } else {
      // Show error if OTP is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }

  // Focus the next field automatically
  void _nextField(String value, FocusNode nextFocus) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Focus nodes for input fields
    final FocusNode focus2 = FocusNode();
    final FocusNode focus3 = FocusNode();
    final FocusNode focus4 = FocusNode();
    final FocusNode focus5 = FocusNode();
    final FocusNode focus6 = FocusNode();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                height: screenHeight * 0.25,
                child: Lottie.asset(
                  'assets/images/Animation - 1737651810989.json', // Replace with your animation path
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: screenHeight * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'A 6-digit code has been sent to\n"$email"!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOtpField(otpController1, onChanged: (value) {
                    _nextField(value, focus2);
                  }),
                  _buildOtpField(otpController2, focusNode: focus2, onChanged: (value) {
                    _nextField(value, focus3);
                  }),
                  _buildOtpField(otpController3, focusNode: focus3, onChanged: (value) {
                    _nextField(value, focus4);
                  }),
                  _buildOtpField(otpController4, focusNode: focus4, onChanged: (value) {
                    _nextField(value, focus5);
                  }),
                  _buildOtpField(otpController5, focusNode: focus5, onChanged: (value) {
                    _nextField(value, focus6);
                  }),
                  _buildOtpField(otpController6, focusNode: focus6),
                ],
              ),
              const SizedBox(height: 30),

              // Custom Button
              MyButton(
                text: isLoading ? 'Submitting...' : 'Submit',
                onTap: isLoading ? null : validateOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build each OTP input field
  Widget _buildOtpField(TextEditingController controller,
      {FocusNode? focusNode, void Function(String)? onChanged}) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '', // Removes the character counter
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
