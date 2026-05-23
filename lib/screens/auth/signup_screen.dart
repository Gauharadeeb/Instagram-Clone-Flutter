import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_api_service.dart';
import '../home/instagram_main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApiService();
  bool _isSubmitting = false;

  String? _validateSignup({
    required String email,
    required String username,
    required String password,
  }) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final capitalPattern = RegExp(r'[A-Z]');
    final specialPattern = RegExp(r'[^A-Za-z0-9]');

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      return 'Please fill email, username, and password.';
    }
    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.length <= 6) {
      return 'Password must be greater than 6 characters.';
    }
    if (!capitalPattern.hasMatch(password)) {
      return 'Password must contain at least one capital letter.';
    }
    if (!specialPattern.hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

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
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                      final email = _emailController.text.trim();
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text;
                      final validationMessage = _validateSignup(
                        email: email,
                        username: username,
                        password: password,
                      );

                      if (validationMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(validationMessage),
                          ),
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);
                      try {
                        final result = await _authApi.createAccount(
                          email: email,
                          username: username,
                          password: password,
                        );

                        if (!context.mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => InstagramMainScreen(
                              username: result.username,
                            ),
                          ),
                        );
                      } on AuthApiException catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.message)),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not connect to the backend.'),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3797EF),
                    ),
                    child: Text(_isSubmitting ? 'Creating...' : 'Submit'),
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
