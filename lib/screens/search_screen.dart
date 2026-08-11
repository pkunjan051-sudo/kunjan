import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/actor.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/movie_card.dart';
import '../widgets/actor_card.dart';
import '../widgets/netflix_hover_card.dart';
import 'movie_details_screen.dart';
import 'actor_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<Movie> _movieResults = [];
  List<Actor> _actorResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  final List<String> _popularTags = [
    'Gujarati',
    'Bollywood',
    'Marvel',
    'Hollywood',
    'Avengers',
    'Shah Rukh Khan',
    'Malhar Thakar',
    'Sci-Fi',
    'Comedy',
    'Action',
  ];

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _movieResults = [];
        _actorResults = [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final movies = await ApiService().searchMovies(query);
    final actors = await ApiService().searchPeople(query);

    if (mounted) {
      setState(() {
        _movieResults = movies;
        _actorResults = actors;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive column count for grid
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover & Search'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () {
                _performSearch('');
              },
            ),
          ),

          // Quick Filter Tags
          if (!_hasSearched) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularTags.map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    backgroundColor: AppColors.surfaceContainer,
                    labelStyle: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                    side: const BorderSide(color: AppColors.glassBorder),
                    onPressed: () {
                      _searchController.text = tag;
                      _performSearch(tag);
                    },
                  );
                }).toList(),
              ),
            ),
          ],

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : !_hasSearched
                    ? _buildEmptySearchPrompt()
                    : (_movieResults.isEmpty && _actorResults.isEmpty)
                        ? _buildNoResultsView()
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification) {
                                NetflixHoverManager().dismissAll();
                              }
                              return false;
                            },
                            child: ListView(
                              padding: const EdgeInsets.all(16.0),
                              children: [
                                // Actors Row
                                if (_actorResults.isNotEmpty) ...[
                                  const Text(
                                    'Artists & Creators',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _actorResults.length,
                                      itemBuilder: (context, index) {
                                        final actor = _actorResults[index];
                                        return ActorCard.fromActor(
                                          actor,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ActorDetailsScreen(actor: actor),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Movies Grid
                                if (_movieResults.isNotEmpty) ...[
                                  Text(
                                    'Movies (${_movieResults.length})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: 0.66,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                    ),
                                    itemCount: _movieResults.length,
                                    itemBuilder: (context, index) {
                                      final movie = _movieResults[index];
                                      return MovieCard(
                                        movie: movie,
                                        width: double.infinity,
                                        height: double.infinity,
                                        margin: EdgeInsets.zero,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailsScreen(movie: movie),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_rounded, size: 64, color: AppColors.surfaceHighest),
          SizedBox(height: 16),
          Text(
            'Explore Movies & Cast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Type a movie title, actor, or genre to begin',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'No Results Found for "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try checking your spelling or search for another title',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
