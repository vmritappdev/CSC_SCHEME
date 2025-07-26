enum Environment { dev, prod }

class AppConfig {
  final String appName;
  final String baseUrl;
  final Environment environment;

  static late final AppConfig _instance;

  AppConfig._internal({
    required this.appName,
    required this.baseUrl,
    required this.environment,
  });

  factory AppConfig({
    required String appName,
    required String baseUrl,
    required Environment environment,
  }) {
    _instance = AppConfig._internal(
      appName: appName,
      baseUrl: baseUrl,
      environment: environment,
    );
    return _instance;
  }

  static AppConfig get instance => _instance;
}

