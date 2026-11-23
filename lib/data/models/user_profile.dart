import 'genre.dart';

class UserProfile {
  const UserProfile({required this.name, required this.favoriteGenres});

  final String name;
  final List<Genre> favoriteGenres;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>)
          .map((name) => Genre.values.byName(name as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'favoriteGenres': favoriteGenres.map((genre) => genre.name).toList(),
    };
  }
}
