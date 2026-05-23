import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const primary = Color(0xFF121212);
  static const accent = Color(0xFFE85D75);
  static const accentSoft = Color(0xFFFFE2E8);
  static const border = Color(0xFFE6E8EC);
  static const textPrimary = Color(0xFF1A1D1F);
  static const textSecondary = Color(0xFF6F767E);
}

class InstagramColors {
  const InstagramColors._();

  static const blue = Color(0xFF3797EF);
  static const likeRed = Color(0xFFFF3040);
  static const storyYellow = Color(0xFFFEDA75);
  static const storyOrange = Color(0xFFFA7E1E);
  static const storyPink = Color(0xFFD62976);
  static const storyPurple = Color(0xFF962FBF);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? const Color(0xFF05080D) : Colors.white;
  }

  static Color surface(BuildContext context) {
    return isDark(context) ? const Color(0xFF10141C) : Colors.white;
  }

  static Color elevatedSurface(BuildContext context) {
    return isDark(context) ? const Color(0xFF171C24) : const Color(0xFFF2F3F5);
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF121212);
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context) ? const Color(0xFFA8ADB7) : const Color(0xFF6F767E);
  }

  static Color border(BuildContext context) {
    return isDark(context) ? const Color(0xFF242A34) : const Color(0xFFE1E4E8);
  }

  static Color input(BuildContext context) {
    return isDark(context) ? const Color(0xFF10141C) : const Color(0xFFFAFAFA);
  }

  static Color modal(BuildContext context) {
    return isDark(context) ? const Color(0xFF10141C) : Colors.white;
  }

  static Color icon(BuildContext context) {
    return textPrimary(context);
  }

  static Color disabled(BuildContext context) {
    return isDark(context) ? const Color(0xFF53606D) : const Color(0xFFB8BEC6);
  }
}
