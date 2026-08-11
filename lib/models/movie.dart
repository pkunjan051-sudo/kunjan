import '../services/api_constants.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<String> genres;
  final int? runtime;
  final double popularity;
  final String? status;
  final String? tagline;
  final String? videoKey;
  final String? videoUrl;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.voteCount = 0,
    required this.releaseDate,
    this.genres = const [],
    this.runtime,
    this.popularity = 0.0,
    this.status,
    this.tagline,
    this.videoKey,
    this.videoUrl,
  });

  String get fullPosterUrl => ApiConstants.getPosterUrl(posterPath);
  String get fullBackdropUrl => ApiConstants.getBackdropUrl(backdropPath);

  String get trailerMp4Url {
    if (videoUrl != null && videoUrl!.trim().isNotEmpty) {
      return videoUrl!.trim();
    }
    final sampleVideos = [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    ];
    return sampleVideos[id.abs() % sampleVideos.length];
  }

  String get effectiveVideoKey {
    if (videoKey != null && videoKey!.trim().isNotEmpty) {
      return videoKey!.trim();
    }
    return getKnownTrailerKeyByTitle(title) ?? '';
  }

  static String? getKnownTrailerKeyByTitle(String title) {
    final lowerTitle = title.toLowerCase().trim();

    // Specific exact movie trailer key mapping
    if (lowerTitle.contains('jawani')) return 'c28M-w4193g';
    if (lowerTitle == 'jawan' || lowerTitle.startsWith('jawan ')) return 'COv52Qyctws';
    if (lowerTitle.contains('dhurandhar: the revenge')) return 'P2-3f1v4zYY';
    if (lowerTitle.contains('dhurandhar')) return 'P2-3f1v4zYY';
    if (lowerTitle.contains('ramayana')) return '0-R4dYjQyEY';
    if (lowerTitle.contains('dilwale')) return 'c25G25x_A9w';
    if (lowerTitle.contains('3 idiots')) return 'K0eDlFX9GMc';
    if (lowerTitle.contains('bhooth bangla')) return 'B11q_S9hJ30';
    if (lowerTitle.contains('bokshi')) return 'W2Q4P1A143d';
    if (lowerTitle.contains('ikka')) return '6amIq_mP46M';
    if (lowerTitle.contains('border 2')) return 'tM21P4A143c';
    if (lowerTitle.contains('fakt mahilao')) return 'K1Z92iA_8eY';
    if (lowerTitle.contains('naadi dosh')) return 'yW0JjHwM-9g';
    if (lowerTitle.contains('tari sathe')) return '2rXWnQ6hA-g';
    if (lowerTitle.contains('kem chho')) return 'fH2S2-yK8yM';
    if (lowerTitle.contains('dhummas')) return '0j8uH3G7s9k';
    if (lowerTitle.contains('lakiro')) return '7bZ8x1Q_YzA';
    if (lowerTitle.contains('chhello divas')) return 'eY3T_s_U44s';
    if (lowerTitle.contains('dharpakad')) return 'Q60P8hQ65Jk';
    if (lowerTitle.contains('romeo')) return '9p4P3xL1zYA';
    if (lowerTitle.contains('bas ek chance')) return '7kP3wL_X1zA';
    if (lowerTitle.contains('chaal jeevi')) return 'fH2S2-yK8yM';
    if (lowerTitle.contains('hellaro')) return '0j8uH3G7s9k';
    if (lowerTitle.contains('3 ekka')) return '7bZ8x1Q_YzA';
    if (lowerTitle.contains('kehvatlal')) return '9kP3wL_X1zY';
    if (lowerTitle.contains('vash')) return 'Q60P8hQ65Jk';
    if (lowerTitle.contains('kutch express')) return '7kP3wL_X1zA';
    if (lowerTitle.contains('pathaan')) return 'vqu4z34wENw';
    if (lowerTitle.contains('animal')) return 'Dydmpfo68DA';
    if (lowerTitle.contains('dangal')) return 'x_7YlGv9u1g';
    if (lowerTitle.contains('rrr')) return 'GY4BgOkktwg';
    if (lowerTitle.contains('kgf')) return 'JKa05nyU85s';
    if (lowerTitle.contains('brahmastra')) return 'V5jVntAC19U';
    if (lowerTitle.contains('stree 2')) return 'kvpt48H60aM';
    if (lowerTitle.contains('fighter')) return '6amIq_mP46M';
    if (lowerTitle.contains('dunki')) return 'tM21P4A143c';
    if (lowerTitle.contains('bhool bhulaiyaa')) return 'W2Q4P1A143d';
    if (lowerTitle.contains('captain marvel')) return 'Z1BCujX3pw8';
    if (lowerTitle.contains('agent carter')) return 'V04p1A143f';
    if (lowerTitle.contains('marvel teacher')) return 'YoHD9XEInc0';
    if (lowerTitle.contains('eternals')) return '0WVSkJlesjU';
    if (lowerTitle.contains('marvel rising')) return 'TcMBFSGVi1c';
    if (lowerTitle.contains('lego marvel')) return 'TcMBFSGVi1c';
    if (lowerTitle.contains('maggie marvel')) return 'Z1BCujX3pw8';
    if (lowerTitle.contains('pokémon') || lowerTitle.contains('pokemon')) return 'uYPbbksJxIg';
    if (lowerTitle.contains('endgame')) return 'TcMBFSGVi1c';
    if (lowerTitle.contains('infinity war')) return '6ZfuNTqbHE8';
    if (lowerTitle.contains('spider-man')) return 'JfVOs4VSpmA';
    if (lowerTitle.contains('iron man')) return '8hYlB38asDY';
    if (lowerTitle.contains('thor')) return 'ue80QwXMRW8';
    if (lowerTitle.contains('black panther')) return 'xjDjIWPwcPU';
    if (lowerTitle.contains('inception')) return 'YoHD9XEInc0';
    if (lowerTitle.contains('interstellar')) return 'zSWdZVtXT7E';
    if (lowerTitle.contains('oppenheimer')) return 'uYPbbksJxIg';
    if (lowerTitle.contains('dark knight')) return 'EXeTwQWrcwY';
    if (lowerTitle.contains('avatar')) return 'd9MyW72ELq0';
    if (lowerTitle.contains('dune')) return 'Way9Dexny3w';
    if (lowerTitle.contains('matrix')) return 'vKQi3bBA1y8';
    if (lowerTitle.contains('titanic')) return 'kVrqfYjkTdQ';
    if (lowerTitle.contains('gladiator')) return 'P5ieIbInFSU';

    return null;
  }

  String get youtubeTrailerUrl => 'https://www.youtube.com/watch?v=$effectiveVideoKey';

  String get youtubeEmbedUrl => 'https://www.youtube.com/embed/$effectiveVideoKey?autoplay=1&mute=0&controls=1';

  String get youtubeThumbnailUrl => 'https://img.youtube.com/vi/$effectiveVideoKey/hqdefault.jpg';

  String get releaseYear {
    if (releaseDate.isEmpty) return 'N/A';
    return releaseDate.split('-').first;
  }

  String get formattedRating => voteAverage.toStringAsFixed(1);

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      parsedGenres = (json['genres'] as List)
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } else if (json['genre_ids'] != null) {
      final genreMap = {
        28: 'Action',
        12: 'Adventure',
        16: 'Animation',
        35: 'Comedy',
        80: 'Crime',
        99: 'Documentary',
        18: 'Drama',
        10751: 'Family',
        14: 'Fantasy',
        36: 'History',
        27: 'Horror',
        10402: 'Music',
        9648: 'Mystery',
        10749: 'Romance',
        878: 'Sci-Fi',
        10770: 'TV Movie',
        53: 'Thriller',
        10752: 'War',
        37: 'Western',
      };
      parsedGenres = (json['genre_ids'] as List)
          .map((id) => genreMap[id] ?? 'Cinema')
          .toList();
    }

    return Movie(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? json['name'] ?? 'Untitled Movie',
      overview: json['overview'] ?? 'No overview available.',
      posterPath: json['poster_path'] ?? json['posterPath'],
      backdropPath: json['backdrop_path'] ?? json['backdropPath'],
      voteAverage: (json['vote_average'] ?? json['voteAverage'] ?? 0.0).toDouble(),
      voteCount: (json['vote_count'] ?? json['voteCount'] ?? 0),
      releaseDate: json['release_date'] ?? json['releaseDate'] ?? '',
      genres: parsedGenres,
      runtime: json['runtime'],
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      status: json['status'],
      tagline: json['tagline'],
      videoKey: json['video_key'] ?? json['videoKey'],
      videoUrl: json['video_url'] ?? json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genres': genres.map((g) => {'name': g}).toList(),
      'runtime': runtime,
      'popularity': popularity,
      'status': status,
      'tagline': tagline,
      'video_key': videoKey,
      'video_url': videoUrl,
    };
  }
}
