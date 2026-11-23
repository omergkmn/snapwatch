import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../models/genre.dart';
import '../models/media_title.dart';
import '../models/recommendation.dart';
import '../models/watch_preference.dart';
import '../services/gemini_service.dart';
import '../services/tmdb_service.dart';

class MediaRepository {
  MediaRepository(this._geminiService, this._tmdbService);

  final GeminiService _geminiService;
  final TmdbService _tmdbService;

  Future<MediaTitle> recognize({
    required Uint8List image,
    required String mimeType,
    required String languageCode,
    void Function()? onRequestSent,
    void Function()? onFirstChunk,
  }) async {
    final json = await _call(
      () => _geminiService.recognizeTitle(
        image: image,
        mimeType: mimeType,
        language: _languageName(languageCode),
        onRequestSent: onRequestSent,
        onFirstChunk: onFirstChunk,
      ),
    );

    if (json['isMediaTitle'] != true || json['title'] == null) {
      throw const AppException(AppErrorType.notMedia);
    }
    return _addCatalogData(MediaTitle.fromJson(json));
  }

  /// The AI recognises the title; TMDB, a real catalogue, supplies the
  /// poster and where it is available in Turkey. If TMDB can't help, the
  /// AI's answer is kept as it is.
  Future<MediaTitle> _addCatalogData(MediaTitle title) async {
    if (!_tmdbService.isConfigured) return title;

    final isSeries = title.type == MediaType.series;
    try {
      final match = await _tmdbService.search(
        query: title.originalTitle ?? title.title,
        isSeries: isSeries,
        year: title.year,
      );
      if (match == null) return title;

      final posterPath = match['poster_path'] as String?;
      final providers = await _tmdbService.turkishProviders(
        id: match['id'] as int,
        isSeries: isSeries,
      );
      return title.copyWith(
        platforms: providers,
        posterUrl: posterPath == null
            ? null
            : _tmdbService.posterUrl(posterPath),
      );
    } on Exception catch (e) {
      debugPrint('TMDB lookup failed: $e');
      return title;
    }
  }

  Future<List<Recommendation>> recommend({
    required List<MediaTitle> watchlist,
    required List<Genre> favoriteGenres,
    required Set<WatchPreference> preferences,
    required String request,
    required String languageCode,
  }) async {
    if (watchlist.isEmpty) {
      throw const AppException(AppErrorType.emptyWatchlist);
    }

    // Film/series filters are exact, so they are applied here instead of
    // being left to the AI.
    final candidates = watchlist.where((title) {
      if (preferences.contains(WatchPreference.filmOnly)) {
        return title.type == MediaType.film;
      }
      if (preferences.contains(WatchPreference.seriesOnly)) {
        return title.type == MediaType.series;
      }
      return true;
    }).toList();
    if (candidates.isEmpty) throw const AppException(AppErrorType.noMatch);

    final json = await _call(
      () => _geminiService.recommend(
        candidates: [
          for (final (index, title) in candidates.indexed)
            {
              'index': index,
              'title': title.originalTitle ?? title.title,
              'type': title.type.name,
              'year': title.year,
              'genres': title.genres,
              'runtimeMinutes': title.runtimeMinutes,
              'seasonCount': title.seasonCount,
            },
        ],
        favoriteGenres: favoriteGenres.map((genre) => genre.name).toList(),
        request: [
          ...preferences.map(_preferenceHint).nonNulls,
          request.trim(),
        ].where((part) => part.isNotEmpty).join('; '),
        language: _languageName(languageCode),
      ),
    );

    final picks = json['picks'] as List<dynamic>? ?? [];
    final usedIndexes = <int>{};
    final recommendations = <Recommendation>[];
    for (final pick in picks.cast<Map<String, dynamic>>()) {
      final index = pick['index'];
      // Ignore anything that does not point to a title in the list.
      if (index is! int || index < 0 || index >= candidates.length) continue;
      if (!usedIndexes.add(index)) continue;
      recommendations.add(
        Recommendation(
          title: candidates[index],
          reason: pick['reason'] as String? ?? '',
        ),
      );
    }
    if (recommendations.isEmpty) throw const AppException(AppErrorType.noMatch);
    return recommendations;
  }

  Future<Map<String, dynamic>> _call(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on FirebaseAIException catch (e) {
      debugPrint('Gemini error: ${e.message}');
      throw const AppException(AppErrorType.unknown);
    } on FormatException catch (e) {
      debugPrint('Gemini returned invalid JSON: $e');
      throw const AppException(AppErrorType.unknown);
    } on Exception catch (e) {
      // Anything else comes from the HTTP layer: offline, timeout, etc.
      debugPrint('Gemini request failed: $e');
      throw const AppException(AppErrorType.network);
    }
  }

  String _languageName(String languageCode) =>
      languageCode == 'tr' ? 'Turkish' : 'English';

  String? _preferenceHint(WatchPreference preference) => switch (preference) {
    WatchPreference.short => 'something short tonight',
    WatchPreference.thrilling => 'something thrilling and tense',
    WatchPreference.light => 'something light and fun',
    WatchPreference.filmOnly || WatchPreference.seriesOnly => null,
  };
}
