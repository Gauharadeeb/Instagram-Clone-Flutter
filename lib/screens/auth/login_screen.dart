import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../home/instagram_feed_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.initialUsername = '',
    this.initialPassword = '',
  });

  final String initialUsername;
  final String initialPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _passwordController = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    'Instagram',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      if (_usernameController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter username and password.'),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const InstagramFeedScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3797EF),
                    ),
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 26),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text('Create new account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: Color(0xFF3797EF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
