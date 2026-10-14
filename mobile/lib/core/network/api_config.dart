class ApiConfig {
  const ApiConfig._();

  // Android Emulator -> localhost de Windows host.
  static const baseUrl = 'http://10.0.2.2:5150';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
}
