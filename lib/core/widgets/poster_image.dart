import 'package:flutter/material.dart';

import 'poster_placeholder.dart';

/// The real poster when there is one, otherwise the drawn placeholder.
/// The placeholder is also shown while the image loads or if it fails.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.title,
    required this.posterUrl,
    this.width = 44,
    this.height = 62,
  });

  final String title;
  final String? posterUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = PosterPlaceholder(
      title: title,
      width: width,
      height: height,
    );
    final url = posterUrl;
    if (url == null) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(width * 0.18),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}
