/// Opens a platform's own search page when its URL format is known,
/// otherwise a web search for the title on that platform.
Uri platformSearchUrl({required String platform, required String title}) {
  final query = Uri.encodeQueryComponent(title);
  final name = platform.toLowerCase();

  if (name.contains('netflix')) {
    return Uri.parse('https://www.netflix.com/search?q=$query');
  }
  if (name.contains('prime')) {
    return Uri.parse('https://www.primevideo.com/search/?phrase=$query');
  }
  if (name.contains('apple')) {
    return Uri.parse('https://tv.apple.com/search?term=$query');
  }
  return webSearchUrl('$title $platform');
}

Uri webSearchUrl(String query) {
  final encoded = Uri.encodeQueryComponent(query);
  return Uri.parse('https://www.google.com/search?q=$encoded');
}
