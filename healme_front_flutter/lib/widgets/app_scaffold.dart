import 'package:flutter/material.dart';
import '../widgets/background_bubbles.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar; // ← Add this
  final Color? backgroundColor;
  final bool showBackgroundBubbles;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar, // ← Add this
    this.backgroundColor,
    this.showBackgroundBubbles = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      appBar: appBar,
      body: Stack(
        children: [
          // Background bubbles
          if (showBackgroundBubbles) BackgroundBubbles(),
          
          // Content
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar, // ← Add this line
    );
  }
}