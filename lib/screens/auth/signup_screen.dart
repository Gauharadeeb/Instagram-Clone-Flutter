import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Instagram',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sign up to see photos and videos from your friends.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  _field('Email', controller: _emailController),
                  const SizedBox(height: 12),
                  _field('Username', controller: _usernameController),
                  const SizedBox(height: 12),
                  _field(
                    'Password',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text;

                      if (email.isEmpty ||
                          username.isEmpty ||
                          password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill email, username, and password.'),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(
                            initialUsername: username,
                            initialPassword: password,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3797EF),
                    ),
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'By signing up, you agree to our Terms, Privacy Policy and Cookies Policy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String hint, {
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
