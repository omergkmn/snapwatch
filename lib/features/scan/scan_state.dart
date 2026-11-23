import '../../core/errors/app_exception.dart';
import '../../data/models/media_title.dart';

sealed class ScanState {
  const ScanState();
}

final class ScanIdle extends ScanState {
  const ScanIdle();
}

final class ScanInProgress extends ScanState {
  const ScanInProgress();
}

final class ScanSuccess extends ScanState {
  const ScanSuccess(this.title);

  final MediaTitle title;
}

final class ScanFailure extends ScanState {
  const ScanFailure(this.error);

  final AppErrorType error;
}
