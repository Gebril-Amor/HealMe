import 'package:flutter/material.dart';
import 'widgets/background_bubbles.dart'; // <-- Make sure path is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );


    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
     
          BackgroundBubbles(),

          
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Image.asset(
                "assets/images/logo.png",
                width: 120,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
