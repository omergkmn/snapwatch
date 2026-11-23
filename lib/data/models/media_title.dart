enum MediaType { film, series }

class MediaTitle {
  const MediaTitle({
    required this.title,
    required this.type,
    this.originalTitle,
    this.year,
    this.genres = const [],
    this.runtimeMinutes,
    this.seasonCount,
    this.creator,
    this.overview = '',
    this.platforms = const [],
    this.posterUrl,
  });

  final String title;
  final MediaType type;
  final String? originalTitle;
  final int? year;
  final List<String> genres;
  final int? runtimeMinutes;
  final int? seasonCount;

  /// Director for a film, creator for a series.
  final String? creator;
  final String overview;
  final List<String> platforms;

  /// From TMDB; null when no poster was found.
  final String? posterUrl;

  factory MediaTitle.fromJson(Map<String, dynamic> json) {
    return MediaTitle(
      title: json['title'] as String,
      type: json['type'] == 'series' ? MediaType.series : MediaType.film,
      originalTitle: _nonEmpty(json['originalTitle'] as String?),
      year: json['year'] as int?,
      genres: List<String>.from(json['genres'] as List<dynamic>? ?? []),
      runtimeMinutes: json['runtimeMinutes'] as int?,
      seasonCount: json['seasonCount'] as int?,
      creator: _nonEmpty(json['creator'] as String?),
      overview: json['overview'] as String? ?? '',
      platforms: List<String>.from(json['platforms'] as List<dynamic>? ?? []),
      posterUrl: json['posterUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.name,
      'originalTitle': originalTitle,
      'year': year,
      'genres': genres,
      'runtimeMinutes': runtimeMinutes,
      'seasonCount': seasonCount,
      'creator': creator,
      'overview': overview,
      'platforms': platforms,
      'posterUrl': posterUrl,
    };
  }

  MediaTitle copyWith({List<String>? platforms, String? posterUrl}) {
    return MediaTitle(
      title: title,
      type: type,
      originalTitle: originalTitle,
      year: year,
      genres: genres,
      runtimeMinutes: runtimeMinutes,
      seasonCount: seasonCount,
      creator: creator,
      overview: overview,
      platforms: platforms ?? this.platforms,
      posterUrl: posterUrl ?? this.posterUrl,
    );
  }
}

/// The AI returns an empty string instead of leaving a field out.
String? _nonEmpty(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
