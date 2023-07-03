import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatter"),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3490FF),
        ),
      ),
    );
  }
}
