import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import '../models/movie.dart';
import '../models/actor.dart';
import '../models/cast_member.dart';

class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();

  bool isExpired(Duration ttl) => DateTime.now().difference(timestamp) > ttl;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  bool get _hasApiKey => ApiConstants.apiKey.trim().isNotEmpty;

  // In-Memory API Response Cache & In-Flight Request Deduplication
  final Map<String, _CacheEntry> _responseCache = {};
  final Map<String, Future<Map<String, dynamic>?>> _inFlightRequests = {};
  static const Duration _defaultCacheTtl = Duration(minutes: 10);

  /// Clear cached response memory
  void clearCache() {
    _responseCache.clear();
    _inFlightRequests.clear();
  }

  // Generic HTTP GET helper with in-memory caching & deduplication
  Future<Map<String, dynamic>?> _get(
    String endpoint, [
    Map<String, String>? queryParams,
    Duration? customTtl,
  ]) async {
    if (!_hasApiKey) return null;

    final params = {'api_key': ApiConstants.apiKey, ...?queryParams};
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(queryParameters: params);
    final cacheKey = uri.toString();
    final ttl = customTtl ?? _defaultCacheTtl;

    // 1. Check memory cache first
    final cached = _responseCache[cacheKey];
    if (cached != null && !cached.isExpired(ttl)) {
      return cached.data;
    }

    // 2. Deduplicate simultaneous in-flight requests for the exact same URI
    if (_inFlightRequests.containsKey(cacheKey)) {
      return _inFlightRequests[cacheKey];
    }

    final future = () async {
      try {
        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          _responseCache[cacheKey] = _CacheEntry(data);
          return data;
        } else {
          debugPrint('API Error [${response.statusCode}]: ${response.body}');
          return null;
        }
      } catch (e) {
        debugPrint('HTTP Request Exception: $e');
        return null;
      } finally {
        _inFlightRequests.remove(cacheKey);
      }
    }();

    _inFlightRequests[cacheKey] = future;
    return future;
  }

  /// Multi-page fetching helper to retrieve multiple pages from TMDB concurrently
  Future<List<Movie>> _fetchMultiPage(String endpoint, Map<String, String> baseParams, {int totalPages = 3}) async {
    final List<Movie> allMovies = [];
    if (!_hasApiKey) return allMovies;
    try {
      final futures = List.generate(totalPages, (index) {
        final pageStr = (index + 1).toString();
        return _get(endpoint, {...baseParams, 'page': pageStr});
      });

      final responses = await Future.wait(futures);
      final Set<int> seenIds = {};

      for (final data in responses) {
        if (data != null && data['results'] != null) {
          final list = data['results'] as List;
          for (final item in list) {
            final movie = Movie.fromJson(item as Map<String, dynamic>);
            if (movie.id > 0 && !seenIds.contains(movie.id)) {
              seenIds.add(movie.id);
              allMovies.add(movie);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Multi-page fetch exception: $e');
    }
    return allMovies;
  }

  /// Fetch Trending Movies (Week)
  Future<List<Movie>> fetchTrendingMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage(ApiConstants.trendingMovies, {}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockTrendingMovies();
  }

  /// Fetch Popular Movies
  Future<List<Movie>> fetchPopularMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage(ApiConstants.popularMovies, {}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockPopularMovies();
  }

  /// Fetch Top Rated Movies
  Future<List<Movie>> fetchTopRatedMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage(ApiConstants.topRatedMovies, {}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockTopRatedMovies();
  }

  /// Fetch Now Playing Movies
  Future<List<Movie>> fetchNowPlayingMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage(ApiConstants.nowPlayingMovies, {}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockNowPlayingMovies();
  }

  /// Fetch Gujarati Movies
  Future<List<Movie>> fetchGujaratiMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage('/discover/movie', {'with_original_language': 'gu', 'sort_by': 'popularity.desc'}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockGujaratiMovies();
  }

  /// Fetch Bollywood Movies (Hindi)
  Future<List<Movie>> fetchBollywoodMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage('/discover/movie', {'with_original_language': 'hi', 'sort_by': 'popularity.desc'}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockBollywoodMovies();
  }

  /// Fetch Marvel Cinematic Universe Movies
  Future<List<Movie>> fetchMarvelMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage(ApiConstants.searchMovies, {'query': 'Marvel'}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockMarvelMovies();
  }

  /// Fetch Hollywood Blockbusters (English)
  Future<List<Movie>> fetchHollywoodMovies({int pages = 3}) async {
    final movies = await _fetchMultiPage('/discover/movie', {'with_original_language': 'en', 'sort_by': 'vote_count.desc'}, totalPages: pages);
    if (movies.isNotEmpty) return movies;
    return _getMockHollywoodMovies();
  }

  /// Search Movies by title
  Future<List<Movie>> searchMovies(String query, {int pages = 2}) async {
    if (query.trim().isEmpty) return [];
    final movies = await _fetchMultiPage(ApiConstants.searchMovies, {'query': query}, totalPages: pages);
    if (movies.isNotEmpty) return movies;

    // Search in fallback mock data across all categories
    final allMocks = [
      ..._getMockTrendingMovies(),
      ..._getMockPopularMovies(),
      ..._getMockTopRatedMovies(),
      ..._getMockNowPlayingMovies(),
      ..._getMockGujaratiMovies(),
      ..._getMockBollywoodMovies(),
      ..._getMockMarvelMovies(),
      ..._getMockHollywoodMovies(),
    ];
    final unique = {for (var m in allMocks) m.id: m}.values.toList();
    return unique
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()) ||
                      m.genres.any((g) => g.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  /// Search Actors / People
  Future<List<Actor>> searchPeople(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _get(ApiConstants.searchPeople, {'query': query});
    if (data != null && data['results'] != null) {
      final list = data['results'] as List;
      return list.map((json) => Actor.fromJson(json as Map<String, dynamic>)).toList();
    }
    final allActors = _getMockActors();
    return allActors
        .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static final Map<int, String?> _trailerKeyCache = {};

  /// Get cached trailer key or fetch dynamically from TMDB API
  Future<String?> getOrFetchTrailerKey(int movieId, String title, {String? initialKey}) async {
    if (initialKey != null && initialKey.trim().isNotEmpty) {
      _trailerKeyCache[movieId] = initialKey.trim();
      return initialKey.trim();
    }
    if (_trailerKeyCache.containsKey(movieId)) {
      return _trailerKeyCache[movieId];
    }

    final key = await fetchMovieTrailerKey(movieId);
    if (key != null && key.trim().isNotEmpty) {
      _trailerKeyCache[movieId] = key.trim();
      return key.trim();
    }

    final knownKey = Movie.getKnownTrailerKeyByTitle(title);
    _trailerKeyCache[movieId] = knownKey;
    return knownKey;
  }

  /// Fetch Single Movie Details with Video/Trailer data
  Future<Movie> fetchMovieDetails(int movieId) async {
    final data = await _get('/movie/$movieId', {'append_to_response': 'videos'});
    if (data != null) {
      String? trailerKey;
      if (data['videos'] != null && data['videos']['results'] != null) {
        final list = data['videos']['results'] as List;
        for (final item in list) {
          if (item['site'] == 'YouTube' && item['type'] == 'Trailer' && item['key'] != null) {
            trailerKey = item['key'].toString();
            break;
          }
        }
        if (trailerKey == null && list.isNotEmpty) {
          trailerKey = list.first['key']?.toString();
        }
      }
      if (trailerKey != null && trailerKey.isNotEmpty) {
        _trailerKeyCache[movieId] = trailerKey;
      }
      final movie = Movie.fromJson(data);
      return Movie(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        backdropPath: movie.backdropPath,
        voteAverage: movie.voteAverage,
        voteCount: movie.voteCount,
        releaseDate: movie.releaseDate,
        genres: movie.genres,
        runtime: movie.runtime,
        popularity: movie.popularity,
        status: movie.status,
        tagline: movie.tagline,
        videoKey: trailerKey ?? movie.videoKey,
      );
    }
    final allMocks = [
      ..._getMockTrendingMovies(),
      ..._getMockPopularMovies(),
      ..._getMockTopRatedMovies(),
      ..._getMockNowPlayingMovies(),
      ..._getMockGujaratiMovies(),
      ..._getMockBollywoodMovies(),
      ..._getMockMarvelMovies(),
      ..._getMockHollywoodMovies(),
    ];
    return allMocks.firstWhere(
      (m) => m.id == movieId,
      orElse: () => _getMockTrendingMovies().first,
    );
  }

  /// Fetch Official YouTube Trailer Key for a Movie
  Future<String?> fetchMovieTrailerKey(int movieId) async {
    final data = await _get('/movie/$movieId/videos');
    if (data != null && data['results'] != null) {
      final list = data['results'] as List;
      for (final item in list) {
        final site = item['site']?.toString();
        final type = item['type']?.toString();
        final key = item['key']?.toString();
        if (site == 'YouTube' && type == 'Trailer' && key != null && key.isNotEmpty) {
          _trailerKeyCache[movieId] = key;
          return key;
        }
      }
      for (final item in list) {
        final key = item['key']?.toString();
        if (item['site']?.toString() == 'YouTube' && key != null && key.isNotEmpty) {
          _trailerKeyCache[movieId] = key;
          return key;
        }
      }
    }
    return null;
  }

  /// Fetch Cast & Crew credits for a movie
  Future<List<CastMember>> fetchMovieCast(int movieId) async {
    final data = await _get('/movie/$movieId/credits');
    if (data != null && data['cast'] != null) {
      final list = data['cast'] as List;
      return list.take(15).map((json) => CastMember.fromJson(json as Map<String, dynamic>)).toList();
    }
    return _getMockCastForMovie(movieId);
  }

  /// Fetch Similar / Recommended Movies
  Future<List<Movie>> fetchSimilarMovies(int movieId) async {
    final data = await _get('/movie/$movieId/similar');
    if (data != null && data['results'] != null) {
      final list = data['results'] as List;
      return list.map((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    }
    return _getMockPopularMovies();
  }

  /// Fetch Single Actor Details & Biography
  Future<Actor> fetchActorDetails(int actorId) async {
    final data = await _get('/person/$actorId', {'append_to_response': 'movie_credits'});
    if (data != null) {
      List<Movie> knownFor = [];
      if (data['movie_credits'] != null && data['movie_credits']['cast'] != null) {
        final castList = data['movie_credits']['cast'] as List;
        knownFor = castList.take(8).map((m) => Movie.fromJson(m as Map<String, dynamic>)).toList();
      }
      return Actor(
        id: data['id'] ?? actorId,
        name: data['name'] ?? 'Artist Profile',
        biography: data['biography'] != null && (data['biography'] as String).isNotEmpty
            ? data['biography']
            : 'Celebrated performer across international cinema.',
        profilePath: data['profile_path'],
        birthday: data['birthday'],
        placeOfBirth: data['place_of_birth'],
        popularity: (data['popularity'] ?? 8.5).toDouble(),
        knownForDepartment: data['known_for_department'] ?? 'Acting',
        knownForMovies: knownFor,
      );
    }
    final allActors = _getMockActors();
    return allActors.firstWhere(
      (a) => a.id == actorId,
      orElse: () => allActors.first,
    );
  }

  // --- Extended Fallback Mock Datasets ---

  List<Movie> _getMockGujaratiMovies() {
    return [
      Movie(
        id: 701,
        title: 'Chaal Jeevi Laiye!',
        overview: 'A workaholic son takes his terminally ill father on an unforgettable road trip to Uttarakhand to fulfill his last wish.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 9.3,
        voteCount: 4200,
        releaseDate: '2019-02-01',
        genres: ['Gujarati', 'Comedy', 'Drama'],
        runtime: 140,
        tagline: 'Life is a journey best shared.',
        videoKey: 'kK8e_9M1N9g',
      ),
      Movie(
        id: 702,
        title: 'Hellaro',
        overview: 'In 1975 in a remote village in Kutch, a group of suppressed women discover freedom and identity through the rhythmic dance of Garba.',
        posterPath: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop',
        voteAverage: 9.1,
        voteCount: 3100,
        releaseDate: '2019-11-08',
        genres: ['Gujarati', 'Drama', 'Musical'],
        runtime: 121,
        tagline: 'Winner of 66th National Film Award for Best Feature Film.',
        videoKey: '1qZkKk407pU',
      ),
      Movie(
        id: 703,
        title: '3 Ekka',
        overview: 'Three childhood friends facing financial trouble try to turn a simple house into a secret casino, leading to hilarious chaotic events.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 8.7,
        voteCount: 2800,
        releaseDate: '2023-08-25',
        genres: ['Gujarati', 'Comedy', 'Drama'],
        runtime: 138,
        tagline: 'Three aces, infinite laughter.',
        videoKey: 'F04uNqN3qE8',
      ),
      Movie(
        id: 704,
        title: 'Chello Divas',
        overview: 'The hilarious story of eight college friends in their final year, capturing the nostalgia, romance, and fun of college life in Gujarat.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop',
        voteAverage: 9.0,
        voteCount: 5200,
        releaseDate: '2015-11-20',
        genres: ['Gujarati', 'Comedy'],
        runtime: 135,
        tagline: 'A new era of Gujarati Cinema.',
        videoKey: 'eY3T_s_U44s',
      ),
      Movie(
        id: 705,
        title: 'Fakt Mahilao Maate',
        overview: 'Chintan Parikh, a young man frustrated by women, gains a divine power allowing him to hear the inner thoughts of all women around him.',
        posterPath: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop',
        voteAverage: 8.5,
        voteCount: 1900,
        releaseDate: '2022-08-19',
        genres: ['Gujarati', 'Comedy', 'Fantasy'],
        runtime: 130,
        tagline: 'Featuring Amitabh Bachchan in a special Gujarati role.',
        videoKey: 'oD2Y2X5tA2w',
      ),
      Movie(
        id: 706,
        title: 'Naadi Dosha',
        overview: 'Riddhi and Kevin fall deeply in love and decide to marry, but face resistance from their traditional families due to Naadi Dosha in their horoscopes.',
        posterPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 8.9,
        voteCount: 2400,
        releaseDate: '2022-06-17',
        genres: ['Gujarati', 'Romance', 'Comedy'],
        runtime: 138,
        tagline: 'Love conquers all horoscopes.',
        videoKey: 'eY3T_s_U44s',
      ),
      Movie(
        id: 707,
        title: 'Kutch Express',
        overview: 'Monghi, a traditional homemaker from Kutch, rediscovers her own artistic talents and self-respect after a shocking revelation in her marriage.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&auto=format&fit=crop',
        voteAverage: 8.6,
        voteCount: 1750,
        releaseDate: '2023-01-06',
        genres: ['Gujarati', 'Drama'],
        runtime: 142,
        tagline: 'Embrace your inner courage.',
        videoKey: '1qZkKk407pU',
      ),
      Movie(
        id: 708,
        title: 'Kehvatlal Parivar',
        overview: 'Raju Kehvatlal and his quirky family navigate eccentric misunderstandings, traditional values, and hilarious business rivalries.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop',
        voteAverage: 8.4,
        voteCount: 1600,
        releaseDate: '2022-05-06',
        genres: ['Gujarati', 'Comedy', 'Family'],
        runtime: 136,
        tagline: 'A family feast of joy and laughter.',
        videoKey: 'F04uNqN3qE8',
      ),
      Movie(
        id: 709,
        title: 'Love Ni Bhavai',
        overview: 'An energetic radio jockey who loves her independence finds herself caught between two completely contrasting suitors with different life visions.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop',
        voteAverage: 8.8,
        voteCount: 3900,
        releaseDate: '2017-11-17',
        genres: ['Gujarati', 'Romance', 'Drama'],
        runtime: 152,
        tagline: 'Dhun Laagi...',
        videoKey: 'kK8e_9M1N9g',
      ),
      Movie(
        id: 710,
        title: 'Vickida No Varghodo',
        overview: 'Vikki\'s long-awaited wedding procession becomes chaotic when three of his ex-girlfriends unexpectedly show up on the wedding day.',
        posterPath: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 8.3,
        voteCount: 1450,
        releaseDate: '2022-07-08',
        genres: ['Gujarati', 'Comedy', 'Romance'],
        runtime: 145,
        tagline: 'The ultimate wedding madness.',
        videoKey: 'F04uNqN3qE8',
      ),
    ];
  }

  List<Movie> _getMockBollywoodMovies() {
    return [
      Movie(
        id: 801,
        title: 'Jawan',
        overview: 'A high-octane action thriller highlighting the emotional journey of a man who is set to rectify the wrongs in society with a team of skilled women.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop',
        voteAverage: 8.8,
        voteCount: 9800,
        releaseDate: '2023-09-07',
        genres: ['Bollywood', 'Action', 'Thriller'],
        runtime: 169,
        tagline: 'Ready to take on the world.',
        videoKey: 'COv52Qyctws',
      ),
      Movie(
        id: 802,
        title: '3 Idiots',
        overview: 'Two friends search for their long lost companion. They revisit their college days and recall the memories of their friend who inspired them to think differently.',
        posterPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 9.2,
        voteCount: 16500,
        releaseDate: '2009-12-25',
        genres: ['Bollywood', 'Comedy', 'Drama'],
        runtime: 170,
        tagline: 'All is Well!',
        videoKey: 'K0eDlFX9GMc',
      ),
      Movie(
        id: 803,
        title: 'RRR',
        overview: 'A fearless revolutionary and an officer in the British force bond closely before discovering each other\'s secret mission in 1920s India.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 9.0,
        voteCount: 14200,
        releaseDate: '2022-03-24',
        genres: ['Bollywood', 'Action', 'Drama'],
        runtime: 187,
        tagline: 'Rise, Roar, Revolt.',
        videoKey: 'f_vbAtFSEc0',
      ),
      Movie(
        id: 804,
        title: 'Stree 2',
        overview: 'The town of Chanderi faces a new terrifying headless entity, prompting Bicky and his squad to team up with an enigmatic woman to save the village.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1200&auto=format&fit=crop',
        voteAverage: 8.6,
        voteCount: 4500,
        releaseDate: '2024-08-15',
        genres: ['Bollywood', 'Horror', 'Comedy'],
        runtime: 147,
        tagline: 'Sarkate Ka Aatank.',
        videoKey: 'kvpt48H60aM',
      ),
      Movie(
        id: 805,
        title: 'Dangal',
        overview: 'Former wrestler Mahavir Singh Phogat trains his daughters Geeta and Babita to become world-class female wrestlers against all societal odds.',
        posterPath: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop',
        voteAverage: 9.1,
        voteCount: 18200,
        releaseDate: '2016-12-23',
        genres: ['Bollywood', 'Biography', 'Drama'],
        runtime: 161,
        tagline: 'Gold is gold, whether won by a boy or a girl.',
        videoKey: 'x_7YlGv9u1g',
      ),
      Movie(
        id: 806,
        title: 'Pathaan',
        overview: 'An exiled RAW field agent Pathaan teams up with ISI agent Rubina to defeat Jim, a rogue former RAW operative planning a lethal biological attack on India.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 8.5,
        voteCount: 12400,
        releaseDate: '2023-01-25',
        genres: ['Bollywood', 'Action', 'Thriller'],
        runtime: 146,
        tagline: 'Apni kursi ki petiyo ko baandh lijiye.',
        videoKey: 'vqu4z34wENw',
      ),
      Movie(
        id: 807,
        title: 'Shershaah',
        overview: 'The heroic story of Vikram Batra, an Indian soldier whose bravery during the 1999 Kargil War awarded him the Param Vir Chakra.',
        posterPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 8.9,
        voteCount: 11500,
        releaseDate: '2021-08-12',
        genres: ['Bollywood', 'War', 'Action', 'Drama'],
        runtime: 135,
        tagline: 'Yeh Dil Maange More!',
        videoKey: 'Q0FTXnefVnA',
      ),
      Movie(
        id: 808,
        title: 'Brahmāstra: Part One – Shiva',
        overview: 'Shiva, a young DJ in Mumbai, discovers his deep connection to the element of fire and holds the power to awaken the ultimate weapon of weapons.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop',
        voteAverage: 8.2,
        voteCount: 8600,
        releaseDate: '2022-09-09',
        genres: ['Bollywood', 'Fantasy', 'Action'],
        runtime: 167,
        tagline: 'The Astraverse begins.',
      ),
      Movie(
        id: 809,
        title: 'Zindagi Na Milegi Dobara',
        overview: 'Three friends take a road trip across Spain before Kabir gets married, confronting their fears, past heartbreaks, and secret desires.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop',
        voteAverage: 9.0,
        voteCount: 13800,
        releaseDate: '2011-07-15',
        genres: ['Bollywood', 'Comedy', 'Drama'],
        runtime: 155,
        tagline: 'Seize the day.',
      ),
      Movie(
        id: 810,
        title: 'Fighter',
        overview: 'Top Air Force aviators form an elite unit named Air Dragons to safeguard the Indian skies against external airborne terrorist threats.',
        posterPath: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop',
        voteAverage: 8.4,
        voteCount: 6200,
        releaseDate: '2024-01-25',
        genres: ['Bollywood', 'Action', 'Thriller'],
        runtime: 166,
        tagline: 'Dominance in the skies.',
      ),
    ];
  }

  List<Movie> _getMockMarvelMovies() {
    return [
      Movie(
        id: 901,
        title: 'Avengers: Endgame',
        overview: 'After the devastating events of Infinity War, the Avengers assemble once more to reverse Thanos\' actions and restore balance to the universe.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop',
        voteAverage: 9.3,
        voteCount: 24500,
        releaseDate: '2019-04-26',
        genres: ['Marvel', 'Action', 'Sci-Fi'],
        runtime: 181,
        tagline: 'Part of the journey is the end.',
        videoKey: 'TcMBFSGVi1c',
      ),
      Movie(
        id: 902,
        title: 'Deadpool & Wolverine',
        overview: 'Wolverine is recovering from his injuries when he crosses paths with the loudmouth Deadpool. They team up to defeat a common enemy.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 8.9,
        voteCount: 11200,
        releaseDate: '2024-07-26',
        genres: ['Marvel', 'Action', 'Comedy'],
        runtime: 128,
        tagline: 'Everyone deserves a happy ending.',
        videoKey: '73_1biulkYk',
      ),
      Movie(
        id: 903,
        title: 'Spider-Man: No Way Home',
        overview: 'With Spider-Man\'s identity now revealed, Peter asks Doctor Strange for help. When a spell goes wrong, dangerous foes from other worlds appear.',
        posterPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 9.1,
        voteCount: 19800,
        releaseDate: '2021-12-17',
        genres: ['Marvel', 'Action', 'Sci-Fi'],
        runtime: 148,
        tagline: 'The Multiverse Unleashed.',
        videoKey: 'JfVOs4VSpmA',
      ),
      Movie(
        id: 904,
        title: 'Iron Man',
        overview: 'After being held captive in an Afghan cave, billionaire industrialist Tony Stark creates a unique weaponized suit of armor to fight evil.',
        posterPath: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop',
        voteAverage: 8.8,
        voteCount: 22100,
        releaseDate: '2008-05-02',
        genres: ['Marvel', 'Action', 'Sci-Fi'],
        runtime: 126,
        tagline: 'Heroes are built, not born.',
        videoKey: '8ugaeA-nMTc',
      ),
      Movie(
        id: 905,
        title: 'Avengers: Infinity War',
        overview: 'The Avengers and their allies must be willing to sacrifice all in an attempt to defeat the powerful Thanos before his blitz of devastation.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop',
        voteAverage: 9.2,
        voteCount: 26100,
        releaseDate: '2018-04-27',
        genres: ['Marvel', 'Action', 'Sci-Fi'],
        runtime: 149,
        tagline: 'An entire universe. Once decision.',
      ),
      Movie(
        id: 906,
        title: 'Guardians of the Galaxy Vol. 3',
        overview: 'Still reeling from the loss of Gamora, Peter Quill rallies his team to defend the universe and protect one of their own from a deadly threat.',
        posterPath: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop',
        voteAverage: 8.8,
        voteCount: 13400,
        releaseDate: '2023-05-05',
        genres: ['Marvel', 'Sci-Fi', 'Adventure'],
        runtime: 150,
        tagline: 'Once more with feeling.',
      ),
      Movie(
        id: 907,
        title: 'Black Panther',
        overview: 'T\'Challa, heir to the hidden kingdom of Wakanda, must step forward to lead his people into a new era and confront a challenger from his father\'s past.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 8.7,
        voteCount: 20500,
        releaseDate: '2018-02-16',
        genres: ['Marvel', 'Action', 'Adventure'],
        runtime: 134,
        tagline: 'Wakanda Forever.',
      ),
      Movie(
        id: 908,
        title: 'Thor: Ragnarok',
        overview: 'Imprisoned on the planet Sakaar, Thor must race against time to return to Asgard and stop Ragnarök at the hands of the ruthless Hela.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 8.8,
        voteCount: 19400,
        releaseDate: '2017-11-03',
        genres: ['Marvel', 'Action', 'Comedy'],
        runtime: 130,
        tagline: 'No Hammer. No Problem.',
      ),
    ];
  }

  List<Movie> _getMockHollywoodMovies() {
    return [
      Movie(
        id: 951,
        title: 'Avatar: The Way of Water',
        overview: 'Jake Sully lives with his newfound family formed on the pandoran planet. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri.',
        posterPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop',
        voteAverage: 8.7,
        voteCount: 14500,
        releaseDate: '2022-12-16',
        genres: ['Hollywood', 'Sci-Fi', 'Adventure'],
        runtime: 192,
        tagline: 'Return to Pandora.',
      ),
      Movie(
        id: 952,
        title: 'The Dark Knight',
        overview: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest tests.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop',
        voteAverage: 9.0,
        voteCount: 15400,
        releaseDate: '2008-07-18',
        genres: ['Hollywood', 'Action', 'Crime'],
        runtime: 152,
        tagline: 'Welcome to a world without rules.',
      ),
      Movie(
        id: 953,
        title: 'Inception',
        overview: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        posterPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop',
        voteAverage: 8.9,
        voteCount: 34200,
        releaseDate: '2010-07-16',
        genres: ['Hollywood', 'Sci-Fi', 'Action'],
        runtime: 148,
        tagline: 'Your mind is the scene of the crime.',
      ),
      Movie(
        id: 954,
        title: 'Interstellar',
        overview: 'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft through a wormhole.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop',
        voteAverage: 9.1,
        voteCount: 32100,
        releaseDate: '2014-11-07',
        genres: ['Hollywood', 'Sci-Fi', 'Drama'],
        runtime: 169,
        tagline: 'Mankind was born on Earth. It was never meant to die here.',
      ),
      Movie(
        id: 955,
        title: 'Gladiator II',
        overview: 'Years after witnessing the death of Maximus at the hands of his uncle, Lucius must enter the Colosseum after his home is conquered by tyrant Emperors.',
        posterPath: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop',
        voteAverage: 8.5,
        voteCount: 5400,
        releaseDate: '2024-11-22',
        genres: ['Hollywood', 'Action', 'History'],
        runtime: 148,
        tagline: 'What we do in life echoes in eternity.',
      ),
      Movie(
        id: 956,
        title: 'Interstellar Odyssey',
        overview: 'A futuristic mission across interstellar jump-gates to protect the final sanctuary of humanity from an ominous galactic storm.',
        posterPath: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop',
        voteAverage: 8.6,
        voteCount: 7800,
        releaseDate: '2025-01-15',
        genres: ['Hollywood', 'Sci-Fi', 'Thriller'],
        runtime: 155,
        tagline: 'Beyond the horizon of spacetime.',
      ),
    ];
  }

  List<Movie> _getMockTrendingMovies() {
    return [
      Movie(
        id: 101,
        title: 'Dune: Part Two',
        overview: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
        posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop',
        voteAverage: 8.6,
        voteCount: 4120,
        releaseDate: '2024-03-01',
        genres: ['Hollywood', 'Sci-Fi', 'Adventure'],
        runtime: 166,
        tagline: 'Long live the fighters.',
      ),
      Movie(
        id: 102,
        title: 'Oppenheimer',
        overview: 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb during World War II.',
        posterPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop',
        voteAverage: 8.9,
        voteCount: 8900,
        releaseDate: '2023-07-21',
        genres: ['Hollywood', 'Drama', 'History'],
        runtime: 180,
        tagline: 'The world forever changes.',
      ),
      ..._getMockGujaratiMovies(),
      ..._getMockBollywoodMovies(),
      ..._getMockMarvelMovies(),
      ..._getMockHollywoodMovies(),
    ];
  }

  List<Movie> _getMockPopularMovies() {
    return [
      ..._getMockMarvelMovies(),
      ..._getMockBollywoodMovies(),
      ..._getMockGujaratiMovies(),
      ..._getMockHollywoodMovies(),
    ];
  }

  List<Movie> _getMockTopRatedMovies() {
    return [
      Movie(
        id: 301,
        title: 'The Godfather',
        overview: 'Spanning from 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family.',
        posterPath: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop',
        voteAverage: 9.2,
        voteCount: 18900,
        releaseDate: '1972-03-14',
        genres: ['Hollywood', 'Drama', 'Crime'],
        runtime: 175,
        tagline: "An offer you can't refuse.",
      ),
      Movie(
        id: 302,
        title: 'The Shawshank Redemption',
        overview: 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
        posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop',
        backdropPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop',
        voteAverage: 9.3,
        voteCount: 26000,
        releaseDate: '1994-09-23',
        genres: ['Hollywood', 'Drama'],
        runtime: 142,
        tagline: 'Fear can hold you prisoner. Hope can set you free.',
      ),
      ..._getMockGujaratiMovies(),
      ..._getMockBollywoodMovies(),
      ..._getMockMarvelMovies(),
    ];
  }

  List<Movie> _getMockNowPlayingMovies() {
    return [
      ..._getMockMarvelMovies(),
      ..._getMockBollywoodMovies(),
      ..._getMockGujaratiMovies(),
      ..._getMockHollywoodMovies(),
    ];
  }

  List<CastMember> _getMockCastForMovie(int movieId) {
    return [
      CastMember(
        id: 501,
        name: 'Timothée Chalamet',
        character: 'Paul Atreides',
        profilePath: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
        order: 1,
      ),
      CastMember(
        id: 502,
        name: 'Zendaya',
        character: 'Chani',
        profilePath: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&auto=format&fit=crop',
        order: 2,
      ),
      CastMember(
        id: 503,
        name: 'Shah Rukh Khan',
        character: 'Vikram Rathore / Azad',
        profilePath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop',
        order: 3,
      ),
      CastMember(
        id: 504,
        name: 'Malhar Thakar',
        character: 'Lead Role',
        profilePath: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop',
        order: 4,
      ),
      CastMember(
        id: 505,
        name: 'Robert Downey Jr.',
        character: 'Tony Stark / Iron Man',
        profilePath: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&auto=format&fit=crop',
        order: 5,
      ),
    ];
  }

  List<Actor> _getMockActors() {
    return [
      Actor(
        id: 501,
        name: 'Shah Rukh Khan',
        biography: 'Shah Rukh Khan, also known by the initialism SRK, is an Indian actor and film producer who works in Hindi films. Referred to in the media as the "Baadshah of Bollywood", he has appeared in more than 90 films.',
        profilePath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
        birthday: '1965-11-02',
        placeOfBirth: 'New Delhi, India',
        popularity: 98.5,
        knownForDepartment: 'Bollywood',
        knownForMovies: _getMockBollywoodMovies(),
      ),
      Actor(
        id: 502,
        name: 'Malhar Thakar',
        biography: 'Malhar Thakar is a prominent Indian actor and producer primarily known for his pioneer work in Gujarati Cinema. Starring in blockbusters such as Chello Divas, 3 Ekka, and Vickida No Varghodo.',
        profilePath: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
        birthday: '1990-06-28',
        placeOfBirth: 'Ahmedabad, Gujarat, India',
        popularity: 94.2,
        knownForDepartment: 'Gujarati Cinema',
        knownForMovies: _getMockGujaratiMovies(),
      ),
      Actor(
        id: 503,
        name: 'Robert Downey Jr.',
        biography: 'Robert John Downey Jr. is an American actor. His career has been characterized by critical and popular success in his youth, followed by a period of substance abuse, and a resurgence as Iron Man in the Marvel Cinematic Universe.',
        profilePath: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop',
        birthday: '1965-04-04',
        placeOfBirth: 'Manhattan, New York, USA',
        popularity: 96.8,
        knownForDepartment: 'Marvel Universe',
        knownForMovies: _getMockMarvelMovies(),
      ),
    ];
  }
}
