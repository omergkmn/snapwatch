import 'media_title.dart';

enum WatchStatus { toWatch, watched }

class WatchlistItem {
  const WatchlistItem({
    required this.title,
    required this.status,
    required this.addedAt,
  });

  final MediaTitle title;
  final WatchStatus status;
  final DateTime addedAt;

  String get id => idOf(title);

  /// The original title stays the same in every app language, so the same
  /// film scanned in Turkish and in English is still one item.
  static String idOf(MediaTitle title) =>
      '${(title.originalTitle ?? title.title).toLowerCase()}|${title.year ?? ''}';

  WatchlistItem copyWith({WatchStatus? status}) {
    return WatchlistItem(
      title: title,
      status: status ?? this.status,
      addedAt: addedAt,
    );
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      title: MediaTitle.fromJson(json['title'] as Map<String, dynamic>),
      status: WatchStatus.values.byName(json['status'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title.toJson(),
      'status': status.name,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
