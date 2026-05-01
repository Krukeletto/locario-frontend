class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'LOCARIO_API_BASE_URL',
    defaultValue: 'http://164.90.173.66:8080',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'LOCARIO_GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '931853293854-q32l0nkenfifmkf3saj3c3tjsj36hd7j.apps.googleusercontent.com',
  );
}
