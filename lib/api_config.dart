class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/php_files',
  );

  static Uri endpoint(String path) {
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse('$normalizedBase/$normalizedPath');
  }
}
