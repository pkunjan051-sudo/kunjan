import '../services/api_constants.dart';
import 'movie.dart';

class Actor {
  final int id;
  final String name;
  final String biography;
  final String? profilePath;
  final String? birthday;
  final String? placeOfBirth;
  final double popularity;
  final String knownForDepartment;
  final List<Movie> knownForMovies;

  Actor({
    required this.id,
    required this.name,
    required this.biography,
    this.profilePath,
    this.birthday,
    this.placeOfBirth,
    this.popularity = 0.0,
    this.knownForDepartment = 'Acting',
    this.knownForMovies = const [],
  });

  String get fullProfileUrl => ApiConstants.getProfileUrl(profilePath);

  factory Actor.fromJson(Map<String, dynamic> json) {
    List<Movie> movies = [];
    if (json['known_for'] != null) {
      movies = (json['known_for'] as List)
          .map((m) => Movie.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return Actor(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown Actor',
      biography: json['biography'] ?? 'No biography available for this artist.',
      profilePath: json['profile_path'] ?? json['profilePath'],
      birthday: json['birthday'],
      placeOfBirth: json['place_of_birth'] ?? json['placeOfBirth'],
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      knownForDepartment: json['known_for_department'] ?? 'Acting',
      knownForMovies: movies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'biography': biography,
      'profile_path': profilePath,
      'birthday': birthday,
      'place_of_birth': placeOfBirth,
      'popularity': popularity,
      'known_for_department': knownForDepartment,
      'known_for': knownForMovies.map((m) => m.toJson()).toList(),
    };
  }
}
