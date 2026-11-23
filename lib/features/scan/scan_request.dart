import 'dart:typed_data';

/// The picked screenshot, passed from home to the scan screen.
class ScanRequest {
  const ScanRequest({required this.image, required this.mimeType});

  final Uint8List image;
  final String mimeType;
}
