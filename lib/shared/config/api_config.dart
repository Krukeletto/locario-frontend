class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'LOCARIO_API_BASE_URL',
    defaultValue: 'http://164.90.173.66:8080',
  );
}
