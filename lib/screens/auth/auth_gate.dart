import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_api_service.dart';
import '../home/instagram_main_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthApiService _authApi = AuthApiService();

  late final Future<SessionUser?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _authApi.validateSavedSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionUser?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _InstagramSplash();
        }

        final sessionUser = snapshot.data;
        if (sessionUser != null) {
          return InstagramMainScreen(username: sessionUser.username);
        }

        return const LoginScreen();
      },
    );
  }
}

class _InstagramSplash extends StatelessWidget {
  const _InstagramSplash();

  @override
  Widget build(BuildContext context) {
    final background = InstagramColors.background(context);
    final foreground = InstagramColors.textPrimary(context);
    final secondary = InstagramColors.textSecondary(context);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: _InstagramGlyph(color: foreground, size: 72)),
            Positioned(
              bottom: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'from',
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.all_inclusive, color: secondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Meta',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstagramGlyph extends StatelessWidget {
  const _InstagramGlyph({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: color, width: size * 0.06),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: size * 0.055),
              ),
            ),
          ),
          Positioned(
            top: size * 0.18,
            right: size * 0.18,
            child: Container(
              width: size * 0.11,
              height: size * 0.11,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
