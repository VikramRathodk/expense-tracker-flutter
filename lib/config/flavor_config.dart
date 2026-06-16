enum Flavor { dev, prod }

class FlavorConfig {
  const FlavorConfig({required this.flavor, required this.apiBaseUrl});

  final Flavor flavor;
  final String apiBaseUrl;

  static FlavorConfig? _instance;

  static void initialize(FlavorConfig config) => _instance = config;

  static FlavorConfig get instance {
    assert(
      _instance != null,
      'FlavorConfig not initialized — call FlavorConfig.initialize() in main()',
    );
    return _instance!;
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}
