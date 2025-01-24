import 'package:flutter/material.dart';

class SignUpNavigationText extends StatelessWidget {
  final String questionText;
  final String actionText;
  final double fontSize;
  final VoidCallback onTap;

  const SignUpNavigationText({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onTap,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: TextStyle(fontSize: fontSize),
        ),
        SizedBox(width: 8.0),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
