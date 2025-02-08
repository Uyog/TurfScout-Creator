import 'package:flutter/material.dart';
import 'package:turf_scout_creator/screens/create.dart';
import 'package:turf_scout_creator/screens/login.dart';
import 'package:turf_scout_creator/screens/otp.dart';
import 'package:turf_scout_creator/screens/password.dart';
import 'package:turf_scout_creator/screens/profile.dart';
import 'package:turf_scout_creator/screens/reset.dart';
import 'package:turf_scout_creator/screens/sign_up.dart';
import 'package:turf_scout_creator/screens/splash.dart';
import 'package:turf_scout_creator/screens/navigation_wrapper.dart';
import 'package:turf_scout_creator/screens/turfs.dart';

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
      home: const SplashScreen(), 
      routes: {
        '/login': (context) => const Login(),
        '/sign': (context) => const SignUp(),
        '/home': (context) => const NavigationWrapper(),
        '/password': (context) => const Password(),
        '/otp': (context) => const Otp(
              email: '',
            ),
        '/reset': (context) => const ResetPassword(),
        '/create': (context) => const Create(), 
        '/turf': (context) => const Turfs(),
        '/profile': (context) => const Profile(),
        

        
      },
    );
  }
}
