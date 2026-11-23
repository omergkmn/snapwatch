import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final _titleModel = _jsonModel(_titleSchema, temperature: 0.2);
  final _recommendModel = _jsonModel(_recommendSchema, temperature: 0.7);

  static const _timeout = Duration(seconds: 45);

  static GenerativeModel _jsonModel(
    Schema schema, {
    required double temperature,
  }) {
    return FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash-lite',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
        temperature: temperature,
        // Both tasks are simple; low thinking keeps answers fast.
        thinkingConfig: ThinkingConfig.withThinkingLevel(ThinkingLevel.low),
      ),
    );
  }

  static final _titleSchema = Schema.object(
    properties: {
      'isMediaTitle': Schema.boolean(
        description:
            'True only if the image clearly shows one specific film '
            'or series.',
      ),
      'title': Schema.string(description: 'Title in the requested language.'),
      'originalTitle': Schema.string(),
      'type': Schema.enumString(enumValues: ['film', 'series']),
      'year': Schema.integer(description: 'Release or first air year.'),
      'genres': Schema.array(items: Schema.string()),
      'runtimeMinutes': Schema.integer(description: 'Films only.'),
      'seasonCount': Schema.integer(description: 'Series only.'),
      'creator': Schema.string(
        description: 'Director for a film, creator for a series.',
      ),
      'overview': Schema.string(description: 'Two or three sentences.'),
      'platforms': Schema.array(
        items: Schema.string(),
        description: 'Streaming services in Turkey that offer it.',
      ),
    },
    // Required fields make the model fill them in every time; when the
    // image is not a film or series they come back empty.
    optionalProperties: [
      'originalTitle',
      'year',
      'runtimeMinutes',
      'seasonCount',
    ],
  );

  static final _recommendSchema = Schema.object(
    properties: {
      'picks': Schema.array(
        items: Schema.object(
          properties: {
            'index': Schema.integer(description: 'Index from the list.'),
            'reason': Schema.string(description: 'One short sentence.'),
          },
        ),
      ),
    },
  );

  Future<Map<String, dynamic>> recognizeTitle({
    required Uint8List image,
    required String mimeType,
    required String language,
  }) async {
    final prompt =
        'Identify the film or series in this image. It may be a poster, a '
        'trailer frame, a streaming app screen or a social media post. Use '
        'the visible title text, artwork and captions. If you are not sure '
        'which specific title it is, set isMediaTitle to false and never '
        'guess. Write the title, genres and overview in $language. Give the '
        'runtime in minutes for a film and the number of seasons for a '
        'series. For '
        'platforms, list only streaming services in Turkey (for example '
        'Netflix, Prime Video, Disney+, HBO Max, Apple TV, MUBI, Tabii, TOD) '
        'where you are fairly confident it is available; otherwise return an '
        'empty list.';

    return _generate(_titleModel, [
      Content.multi([TextPart(prompt), InlineDataPart(mimeType, image)]),
    ]);
  }

  /// [candidates] is the user's watchlist; picks refer to it by index.
  Future<Map<String, dynamic>> recommend({
    required List<Map<String, dynamic>> candidates,
    required List<String> favoriteGenres,
    required String request,
    required String language,
  }) {
    final prompt =
        'Help the user decide what to watch tonight. Choose up to 3 titles '
        'only from the numbered list below, best match first, and never '
        'suggest anything that is not in the list. Consider the request and '
        'the favourite genres. For each pick write one short sentence in '
        '$language that tells the user why it fits tonight. Speak to the '
        'user informally (in Turkish use "sen", never "siz").\n\n'
        'Request: ${request.isEmpty ? 'no preference' : request}\n'
        'Favourite genres: ${favoriteGenres.join(', ')}\n'
        'List: ${jsonEncode(candidates)}';

    return _generate(_recommendModel, [Content.text(prompt)]);
  }

  Future<Map<String, dynamic>> _generate(
    GenerativeModel model,
    List<Content> content,
  ) async {
    final response = await model.generateContent(content).timeout(_timeout);
    return jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
  }
}
