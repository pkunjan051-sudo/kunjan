/// API Constants for CinemaCentral
/// 
/// Replace [apiKey] with your TMDB (The Movie Database) API Key v3.
/// Get your free API key at: https://www.themoviedb.org/settings/api
class ApiConstants {
  // Store API key securely here.
  static const String apiKey = '8a2e978635066dc6c7a365d3af1be5d9'; // <-- Put your TMDB API Key v3 here (e.g. 'a1b2c3d4e5f6...')

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String baseImageUrl = 'https://image.tmdb.org/t/p';

  // Helper endpoints
  static const String trendingMovies = '/trending/movie/week';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String searchMovies = '/search/movie';
  static const String searchPeople = '/search/person';
  static const String genres = '/genre/movie/list';

  // Fallback high-reliability image URLs
  static const String fallbackPosterUrl = 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500&auto=format&fit=crop';
  static const String fallbackBackdropUrl = 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1280&auto=format&fit=crop';
  static const String fallbackProfileUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop';

  // Image size helper methods
  static String getPosterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.trim().isEmpty) {
      return fallbackPosterUrl;
    }
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final formattedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseImageUrl/$size$formattedPath';
  }

  static String getBackdropUrl(String? path, {String size = 'w1280'}) {
    if (path == null || path.trim().isEmpty) {
      return fallbackBackdropUrl;
    }
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final formattedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseImageUrl/$size$formattedPath';
  }

  static String getProfileUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.trim().isEmpty) {
      return fallbackProfileUrl;
    }
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final formattedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseImageUrl/$size$formattedPath';
  }
}
