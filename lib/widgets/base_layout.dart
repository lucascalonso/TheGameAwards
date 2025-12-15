import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BaseLayout extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? floatingActionButton;

  const BaseLayout({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      // The Stack allows placing the image behind the content
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // 0.3 visible = 0.7 transparent (adjust as needed)
              child: Image.asset(
                'assets/images/gameawardsbg1.jpg', // Make sure the extension is correct (.jpg or .png)
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Screen Content
          Positioned.fill(child: body),
        ],
      ),
    );
  }
}
