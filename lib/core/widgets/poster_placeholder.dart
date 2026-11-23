import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A poster-like tile drawn from the title, since the app has no real
/// poster images. The same title always gets the same colours.
class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({
    super.key,
    required this.title,
    this.width = 44,
    this.height = 62,
  });

  final String title;
  final double width;
  final double height;

  static const _gradients = [
    [Color(0xFF4A4E57), Color(0xFF16171B)],
    [Color(0xFF5A5650), Color(0xFF1A1917)],
    [Color(0xFF3B4250), Color(0xFF101217)],
    [Color(0xFF4F4A56), Color(0xFF17151A)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[title.hashCode.abs() % _gradients.length];
    final initial = title.isEmpty ? '?' : title.characters.first.toUpperCase();

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.18),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: AppFonts.title,
          fontSize: width * 0.5,
          fontWeight: FontWeight.w600,
          color: AppColors.silver,
        ),
      ),
    );
  }
}
