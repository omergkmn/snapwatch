import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../data/repositories/media_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit(this._mediaRepository, this._subscriptionRepository)
    : super(const ScanIdle());

  final MediaRepository _mediaRepository;
  final SubscriptionRepository _subscriptionRepository;

  Future<void> scan({
    required Uint8List image,
    required String mimeType,
    required String languageCode,
  }) async {
    if (state is ScanInProgress) return;

    emit(const ScanInProgress());
    try {
      final title = await _mediaRepository.recognize(
        image: image,
        mimeType: mimeType,
        languageCode: languageCode,
      );
      // Only a successful recognition uses up a free scan.
      await _subscriptionRepository.recordScan();
      emit(ScanSuccess(title));
    } on AppException catch (e) {
      emit(ScanFailure(e.type));
    }
  }
}
