class ApiConfig {
  static const String baseUrl = 'https://instagram-clone-flutter-1.onrender.com';

  static String resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      return url;
    }

    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }

    return '$baseUrl/$url';
  }
}
