import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../components/button.dart'; // Ensure this file exists and is correctly imported

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _pageController;
  Timer? _timer;

  final List<Map<String, String>> _slides = [
    {
      'animationAsset': 'assets/images/Football player animation.json',
      'title': 'Welcome to TurfScout',
      'description': 'Find and book the best turf for your game!',
    },
    {
      'animationAsset': 'assets/images/Grass animation.json',
      'title': 'Explore Green Turfs',
      'description': 'A place where you can enjoy lush green fields!',
    },
    {
      'animationAsset': 'assets/images/Booking animation.json',
      'title': 'Easy Booking',
      'description': 'Book a turf in just a few taps!',
    },
  ];

  static const int _initialPageOffset = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPageOffset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the first slide is displayed when the page loads
      _pageController.jumpToPage(_initialPageOffset);
    });

    // Auto-scroll the carousel
   _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
  if (_pageController.hasClients) {
    final nextPage = (_pageController.page?.toInt() ?? _initialPageOffset) + 1;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }
});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // PageView for slides
          PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              // Loop through the slides
              final slide = _slides[index % _slides.length];
              return Slide(
                animationAsset: slide['animationAsset']?? 'assets/images/default.json',
                title: slide['title']?? 'Default Title',
                description: slide['description']?? 'Default Description',
              );
            },
          ),
          // Dots indicator
          Positioned(
            bottom: screenHeight * 0.15, // 15% from the bottom
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    final currentPage = _pageController.page?.toInt() ?? 0;
                    return _buildDot(index, currentPage % _slides.length);
                  },
                ),
              ),
            ),
          ),
          // Get Started button
          Positioned(
            bottom: screenHeight * 0.05, // 5% from the bottom
            left: screenWidth * 0.2,
            right: screenWidth * 0.2,
            child: MyButton(
              text: 'Get Started',
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, int currentIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentIndex ? Colors.green : Colors.grey,
      ),
    );
  }
}

class Slide extends StatelessWidget {
  final String animationAsset;
  final String title;
  final String description;

  const Slide({
    super.key,
    required this.animationAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie Animation
        SizedBox(
          height: screenHeight * 0.4, // 40% of screen height
          child: Lottie.asset(
            animationAsset,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'Animation failed to load',
                style: TextStyle(color: Colors.red, fontSize: 16),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Title
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.05),
          child: Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
