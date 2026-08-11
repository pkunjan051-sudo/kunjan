import 'package:flutter/material.dart';
import '../models/actor.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/horizontal_movie_list.dart';
import '../widgets/safe_network_image.dart';
import 'movie_details_screen.dart';

class ActorDetailsScreen extends StatefulWidget {
  final Actor actor;

  const ActorDetailsScreen({super.key, required this.actor});

  @override
  State<ActorDetailsScreen> createState() => _ActorDetailsScreenState();
}

class _ActorDetailsScreenState extends State<ActorDetailsScreen> {
  late Actor _actor;
  bool _isBioExpanded = false;

  @override
  void initState() {
    super.initState();
    _actor = widget.actor;
    _loadActorFullDetails();
  }

  Future<void> _loadActorFullDetails() async {
    final fullActor = await ApiService().fetchActorDetails(_actor.id);
    if (mounted) {
      setState(() {
        _actor = fullActor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_actor.name),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Actor Avatar & Header Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SafeNetworkImage(
                      imageUrl: _actor.fullProfileUrl,
                      width: 110,
                      height: 155,
                      fit: BoxFit.cover,
                      title: _actor.name,
                      icon: Icons.person_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _actor.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _actor.knownForDepartment.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_actor.birthday != null && _actor.birthday!.isNotEmpty) ...[
                        _buildInfoRow(Icons.cake_rounded, 'Born: ${_actor.birthday}'),
                        const SizedBox(height: 6),
                      ],
                      if (_actor.placeOfBirth != null && _actor.placeOfBirth!.isNotEmpty) ...[
                        _buildInfoRow(Icons.place_rounded, _actor.placeOfBirth!),
                        const SizedBox(height: 6),
                      ],
                      _buildInfoRow(
                        Icons.trending_up_rounded,
                        'Popularity Score: ${_actor.popularity.toStringAsFixed(1)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Biography Section
            const Text(
              'Biography',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _actor.biography,
              maxLines: _isBioExpanded ? null : 5,
              overflow: _isBioExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
            if (_actor.biography.length > 200)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBioExpanded = !_isBioExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    _isBioExpanded ? 'Show Less' : 'Read Full Biography',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Known For Filmography
            if (_actor.knownForMovies.isNotEmpty) ...[
              HorizontalMovieList(
                title: 'Known For',
                movies: _actor.knownForMovies,
                onMovieTap: (movie) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(movie: movie),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
