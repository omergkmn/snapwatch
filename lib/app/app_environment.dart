enum AppEnvironment {
  dev,
  prod;

  bool get isDev => this == AppEnvironment.dev;
}
