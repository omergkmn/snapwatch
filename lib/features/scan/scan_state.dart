import '../../core/errors/app_exception.dart';
import '../../data/models/media_title.dart';

/// Real moments of a scan, in order.
enum ScanStep {
  /// The image is being sent.
  reading,

  /// The request is out; the AI is working on it.
  recognizing,

  /// The answer has started to arrive.
  details,

  /// The answer is complete and is being saved.
  finishing,
}

sealed class ScanState {
  const ScanState();
}

final class ScanInProgress extends ScanState {
  const ScanInProgress(this.step);

  final ScanStep step;
}

final class ScanSuccess extends ScanState {
  const ScanSuccess(this.title);

  final MediaTitle title;
}

final class ScanFailure extends ScanState {
  const ScanFailure(this.error);

  final AppErrorType error;
}
