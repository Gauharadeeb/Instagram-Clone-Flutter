import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  static const _background = Color(0xFF05080D);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: Icon(
            Icons.video_collection_outlined,
            color: Colors.white,
            size: 52,
          ),
        ),
      ),
    );
  }
}
