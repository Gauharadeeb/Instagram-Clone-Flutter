import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

class ClassicoApp extends StatelessWidget {
  const ClassicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Auth UI',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
