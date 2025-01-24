import 'package:flutter/material.dart';
import 'package:turf_scout_creator/screens/home.dart';
import 'package:turf_scout_creator/screens/login.dart';
import 'package:turf_scout_creator/screens/otp.dart';
import 'package:turf_scout_creator/screens/password.dart';
import 'package:turf_scout_creator/screens/reset.dart';
import 'package:turf_scout_creator/screens/sign_up.dart';
import 'package:turf_scout_creator/screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => Login(),
        '/sign': (context) => SignUp(),
        '/home': (context) => HomePage(),
        '/password': (context) => Password(),
        '/otp': (context) => Otp(
              email: '',
            ),
        '/reset': (context) => ResetPassword()
      },
    );
  }
}
