class ApiConfig {
  const ApiConfig._();

  static const baseUrl = 'http://10.0.2.2:5150';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);

  static String resolveFileUrl(String? path) {
    final value = path?.trim() ?? '';

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }
}
