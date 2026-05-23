import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_api_service.dart';
import '../../services/token_storage_service.dart';
import '../home/instagram_main_screen.dart';
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
  final _authApi = AuthApiService();
  final _storage = TokenStorageService();
  bool _isSubmitting = false;
  bool? _isBackendConnected;
  String _languageCode = 'en';

  static const _languages = [
    _LoginLanguage(code: 'en', label: 'English (US)'),
    _LoginLanguage(code: 'hi', label: 'हिन्दी'),
    _LoginLanguage(code: 'ur', label: 'اردو'),
    _LoginLanguage(code: 'bn', label: 'বাংলা'),
  ];

  static const _translations = {
    'en': {
      'chooseLanguage': 'Choose your language',
      'username': 'Username, email or mobile number',
      'password': 'Password',
      'login': 'Log in',
      'forgot': 'Forgot password?',
      'create': 'Create new account',
    },
    'hi': {
      'chooseLanguage': 'अपनी भाषा चुनें',
      'username': 'यूज़रनेम, ईमेल या मोबाइल नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉग इन करें',
      'forgot': 'पासवर्ड भूल गए?',
      'create': 'नया अकाउंट बनाएं',
    },
    'ur': {
      'chooseLanguage': 'اپنی زبان منتخب کریں',
      'username': 'یوزرنیم، ای میل یا موبائل نمبر',
      'password': 'پاس ورڈ',
      'login': 'لاگ اِن کریں',
      'forgot': 'پاس ورڈ بھول گئے؟',
      'create': 'نیا اکاؤنٹ بنائیں',
    },
    'bn': {
      'chooseLanguage': 'আপনার ভাষা নির্বাচন করুন',
      'username': 'ইউজারনেম, ইমেইল বা মোবাইল নম্বর',
      'password': 'পাসওয়ার্ড',
      'login': 'লগ ইন',
      'forgot': 'পাসওয়ার্ড ভুলে গেছেন?',
      'create': 'নতুন অ্যাকাউন্ট তৈরি করুন',
    },
  };

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _loadSavedLanguage();
    _checkBackendConnection();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await _storage.getLoginLanguage();
    if (!mounted || savedLanguage == null) {
      return;
    }
    if (_languages.any((language) => language.code == savedLanguage)) {
      setState(() => _languageCode = savedLanguage);
    }
  }

  Future<void> _checkBackendConnection() async {
    final isConnected = await _authApi.isBackendConnected();
    if (!mounted) {
      return;
    }

    setState(() => _isBackendConnected = isConnected);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _translations[_languageCode] ?? _translations['en']!;
    final selectedLanguage = _languages.firstWhere(
      (language) => language.code == _languageCode,
      orElse: () => _languages.first,
    );
    final isRtl = _languageCode == 'ur';
    final background = InstagramColors.background(context);
    final primaryText = InstagramColors.textPrimary(context);
    final secondaryText = InstagramColors.textSecondary(context);
    final isDarkMode = InstagramColors.isDark(context);
    final inputColor = isDarkMode ? InstagramColors.input(context) : Colors.white;
    final borderColor = isDarkMode
        ? InstagramColors.border(context)
        : const Color(0xFFE4E4E4);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.arrow_back,
                          color: primaryText,
                          size: 31,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _showLanguageSheet,
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedLanguage.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: secondaryText,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final logoTopGap = (constraints.maxHeight * 0.16)
                      .clamp(56.0, 122.0)
                      .toDouble();
                  final formTopGap = (constraints.maxHeight * 0.12)
                      .clamp(42.0, 104.0)
                      .toDouble();

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 390),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: logoTopGap),
                            Center(
                              child:
                                  _InstagramLogo(backgroundColor: background),
                            ),
                            SizedBox(height: formTopGap),
                            TextField(
                              controller: _usernameController,
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              style:
                                  TextStyle(color: primaryText, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: text['username'],
                                hintStyle: TextStyle(
                                  color: secondaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: inputColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide:
                                      BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: const BorderSide(
                                    color: InstagramColors.blue,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              style:
                                  TextStyle(color: primaryText, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: text['password'],
                                hintStyle: TextStyle(
                                  color: secondaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: inputColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide:
                                      BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: const BorderSide(
                                    color: InstagramColors.blue,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () async {
                                      if (_usernameController.text.isEmpty ||
                                          _passwordController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Enter username and password.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => _isSubmitting = true);
                                      try {
                                        final result = await _authApi.login(
                                          username:
                                              _usernameController.text.trim(),
                                          password: _passwordController.text,
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(error.message)),
                                        );
                                      } catch (_) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not connect to the backend.',
                                            ),
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(
                                            () => _isSubmitting = false,
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: InstagramColors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: Text(
                                _isSubmitting
                                    ? '${text["login"]}...'
                                    : text['login']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                text['forgot']!,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: InstagramColors.blue, width: 1),
                  foregroundColor: InstagramColors.blue,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(
                  text['create']!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.all_inclusive,
                    color: secondaryText,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Meta',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageSheet() async {
    final text = _translations[_languageCode] ?? _translations['en']!;
    final modalColor = InstagramColors.modal(context);
    final primaryText = InstagramColors.textPrimary(context);
    final borderColor = InstagramColors.border(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: modalColor,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: _languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF737A86),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    text['chooseLanguage']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final language in _languages)
                    _LanguageOptionTile(
                      language: language,
                      isSelected: language.code == _languageCode,
                      textColor: primaryText,
                      borderColor: borderColor,
                      onTap: () => _selectLanguage(language.code),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectLanguage(String languageCode) async {
    setState(() => _languageCode = languageCode);
    await _storage.saveLoginLanguage(languageCode);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _InstagramLogo extends StatelessWidget {
  const _InstagramLogo({required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return _InstagramGlyph(
      backgroundColor: backgroundColor,
      size: 60,
    );
  }
}

class _InstagramGlyph extends StatelessWidget {
  const _InstagramGlyph({
    required this.backgroundColor,
    required this.size,
  });

  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFFFEDA75),
        Color(0xFFFA7E1E),
        Color(0xFFD62976),
        Color(0xFF962FBF),
        Color(0xFF4F5BD5),
      ],
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        gradient: gradient,
      ),
      padding: EdgeInsets.all(size * 0.07),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size * 0.18),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: size * 0.36,
                height: size * 0.36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                ),
                padding: EdgeInsets.all(size * 0.075),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              top: size * 0.16,
              right: size * 0.16,
              child: Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: const BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginLanguage {
  const _LoginLanguage({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.language,
    required this.isSelected,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  final _LoginLanguage language;
  final bool isSelected;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: Border(bottom: BorderSide(color: borderColor)),
      title: Text(
        language.label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: InstagramColors.blue)
          : const SizedBox(width: 24),
    );
  }
}
