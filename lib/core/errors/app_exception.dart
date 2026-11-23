enum AppErrorType { network, notMedia, emptyWatchlist, noMatch, unknown }

class AppException implements Exception {
  const AppException(this.type);

  final AppErrorType type;
}
