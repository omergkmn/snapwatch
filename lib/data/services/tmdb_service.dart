import 'dart:convert';

import 'package:http/http.dart' as http;

/// The Movie Database: real posters and where a title can be watched.
/// The API key is passed at build time and never committed.
class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _imageUrl = 'https://image.tmdb.org/t/p/w342';
  static const _timeout = Duration(seconds: 8);

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Returns the best match as raw JSON, or null when nothing is found.
  Future<Map<String, dynamic>?> search({
    required String query,
    required bool isSeries,
    int? year,
  }) async {
    final json = await _get(isSeries ? '/search/tv' : '/search/movie', {
      'query': query,
      if (year != null) isSeries ? 'first_air_date_year' : 'year': '$year',
    });
    final results = json['results'] as List<dynamic>? ?? [];
    return results.isEmpty ? null : results.first as Map<String, dynamic>;
  }

  /// Streaming services in Turkey: subscription first, then rent and buy.
  Future<List<String>> turkishProviders({
    required int id,
    required bool isSeries,
  }) async {
    final json = await _get(
      '/${isSeries ? 'tv' : 'movie'}/$id/watch/providers',
      const {},
    );
    final turkey = (json['results'] as Map<String, dynamic>?)?['TR'];
    if (turkey is! Map<String, dynamic>) return [];

    final names = <String>{};
    for (final type in ['flatrate', 'rent', 'buy']) {
      for (final provider in turkey[type] as List<dynamic>? ?? []) {
        names.add(
          (provider as Map<String, dynamic>)['provider_name'] as String,
        );
      }
    }
    return names.toList();
  }

  String posterUrl(String posterPath) => '$_imageUrl$posterPath';

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl$path')
              .replace(queryParameters: {...query, 'api_key': _apiKey}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('TMDB ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
