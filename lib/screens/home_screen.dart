import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/horizontal_movie_list.dart';
import '../widgets/netflix_hover_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_view.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSearchTap;

  const HomeScreen({super.key, required this.onSearchTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _trendingMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _gujaratiMovies = [];
  List<Movie> _bollywoodMovies = [];
  List<Movie> _marvelMovies = [];
  List<Movie> _hollywoodMovies = [];
  
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedGenre = 'All';

  final List<String> _genres = [
    'All',
    'Gujarati',
    'Bollywood',
    'Marvel',
    'Hollywood',
    'Sci-Fi',
    'Action',
    'Drama',
    'Comedy',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllMovies();
  }

  Future<void> _loadAllMovies() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        ApiService().fetchTrendingMovies(),
        ApiService().fetchTopRatedMovies(),
        ApiService().fetchGujaratiMovies(),
        ApiService().fetchBollywoodMovies(),
        ApiService().fetchMarvelMovies(),
        ApiService().fetchHollywoodMovies(),
      ]);

      if (mounted) {
        setState(() {
          _trendingMovies = results[0];
          _topRatedMovies = results[1];
          _gujaratiMovies = results[2];
          _bollywoodMovies = results[3];
          _marvelMovies = results[4];
          _hollywoodMovies = results[5];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  List<Movie> _filterByGenre(List<Movie> list) {
    if (_selectedGenre == 'All') return list;
    final target = _selectedGenre.toLowerCase().trim();

    return list.where((m) {
      final titleLower = m.title.toLowerCase();

      if (target == 'gujarati') {
        return m.genres.any((g) => g.toLowerCase() == 'gujarati') ||
            titleLower.contains('gujarati') ||
            titleLower.contains('chaal jeevi') ||
            titleLower.contains('hellaro') ||
            titleLower.contains('chhello') ||
            titleLower.contains('fakt mahilao') ||
            titleLower.contains('naadi') ||
            titleLower.contains('kem chho') ||
            titleLower.contains('dhummas') ||
            titleLower.contains('tari sathe') ||
            titleLower.contains('lakiro') ||
            titleLower.contains('romeo');
      }

      if (target == 'bollywood') {
        return m.genres.any((g) => g.toLowerCase() == 'bollywood') ||
            titleLower.contains('jawan') ||
            titleLower.contains('pathaan') ||
            titleLower.contains('dangal') ||
            titleLower.contains('stree') ||
            titleLower.contains('rrr') ||
            titleLower.contains('brahmastra') ||
            titleLower.contains('fighter') ||
            titleLower.contains('3 idiots');
      }

      if (target == 'marvel') {
        return m.genres.any((g) => g.toLowerCase() == 'marvel') ||
            titleLower.contains('marvel') ||
            titleLower.contains('avengers') ||
            titleLower.contains('spider-man') ||
            titleLower.contains('iron man') ||
            titleLower.contains('thor') ||
            titleLower.contains('black panther') ||
            titleLower.contains('deadpool') ||
            titleLower.contains('guardians');
      }

      if (target == 'hollywood') {
        return m.genres.any((g) => g.toLowerCase() == 'hollywood') ||
            titleLower.contains('avatar') ||
            titleLower.contains('dark knight') ||
            titleLower.contains('inception') ||
            titleLower.contains('interstellar') ||
            titleLower.contains('gladiator') ||
            titleLower.contains('dune') ||
            titleLower.contains('oppenheimer') ||
            titleLower.contains('godfather') ||
            titleLower.contains('shawshank');
      }

      return m.genres.any((g) => g.toLowerCase() == target);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'CINEMA',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'CENTRAL',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
              onPressed: widget.onSearchTap,
              tooltip: 'Search Movies',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainer,
        onRefresh: _loadAllMovies,
        child: _hasError
            ? ErrorView(onRetry: _loadAllMovies)
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    NetflixHoverManager().dismissAll();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genre Selector Bar
                    SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _genres.length,
                        itemBuilder: (context, index) {
                          final genre = _genres[index];
                          final isSelected = _selectedGenre == genre;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              child: FilterChip(
                                label: Text(genre),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedGenre = genre;
                                  });
                                },
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surfaceContainer,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                showCheckmark: false,
                                elevation: isSelected ? 4 : 0,
                                shadowColor: AppColors.primary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.12),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Featured Hero Banner Carousel
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: HeroSkeleton(),
                      )
                    else
                      HeroCarousel(
                        movies: _filterByGenre([
                          ..._trendingMovies,
                          ..._gujaratiMovies,
                          ..._bollywoodMovies,
                          ..._marvelMovies,
                        ]).take(6).toList(),
                        onMovieTap: (movie) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // Gujarati Movies Rail
                    if (_selectedGenre == 'All' || _selectedGenre == 'Gujarati')
                      HorizontalMovieList(
                        title: 'Gujarati Blockbusters 🚩',
                        movies: _gujaratiMovies,
                        isLoading: _isLoading,
                        onSeeAllTap: widget.onSearchTap,
                        onMovieTap: (movie) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Bollywood Movies Rail
                    if (_selectedGenre == 'All' || _selectedGenre == 'Bollywood')
                      HorizontalMovieList(
                        title: 'Bollywood Hits 🌟',
                        movies: _bollywoodMovies,
                        isLoading: _isLoading,
                        onSeeAllTap: widget.onSearchTap,
                        onMovieTap: (movie) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Marvel Cinematic Universe Rail
                    if (_selectedGenre == 'All' || _selectedGenre == 'Marvel')
                      HorizontalMovieList(
                        title: 'Marvel Cinematic Universe ⚡',
                        movies: _marvelMovies,
                        isLoading: _isLoading,
                        onSeeAllTap: widget.onSearchTap,
                        onMovieTap: (movie) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Hollywood Rail
                    if (_selectedGenre == 'All' || _selectedGenre == 'Hollywood')
                      HorizontalMovieList(
                        title: 'Hollywood Classics & Blockbusters 🎬',
                        movies: _hollywoodMovies,
                        isLoading: _isLoading,
                        onSeeAllTap: widget.onSearchTap,
                        onMovieTap: (movie) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Trending Now Rail
                    HorizontalMovieList(
                      title: 'Trending Worldwide 🔥',
                      movies: _filterByGenre(_trendingMovies),
                      isLoading: _isLoading,
                      onSeeAllTap: widget.onSearchTap,
                      onMovieTap: (movie) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(movie: movie),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Top Rated Cinema Rail
                    HorizontalMovieList(
                      title: 'Top Rated All Time ⭐',
                      movies: _filterByGenre(_topRatedMovies),
                      isLoading: _isLoading,
                      onSeeAllTap: widget.onSearchTap,
                      onMovieTap: (movie) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(movie: movie),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

