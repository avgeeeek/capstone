import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// stall_list_screen.dart is embedded inside student_home_screen.dart
// This file provides a standalone StallListScreen for potential navigation use

class StallListScreen extends StatelessWidget {
  const StallListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Stalls')),
      body: const Center(
        child: Text(
          'Stall list is shown in the home screen.',
          style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
