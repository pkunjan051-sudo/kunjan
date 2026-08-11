import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_constants.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../widgets/safe_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isKeyConfigured = ApiConstants.apiKey.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cinema Profile'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceHigh,
                        ),
                        child: ClipOval(
                          child: SafeNetworkImage(
                            imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
                            fallbackUrl: ApiConstants.fallbackProfileUrl,
                            fit: BoxFit.cover,
                            title: 'Alex Mercer',
                            icon: Icons.person_rounded,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alex Mercer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO FILM CRITIC',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Stats Grid
            ValueListenableBuilder<List<Movie>>(
              valueListenable: FavoritesService().favoritesNotifier,
              builder: (context, favorites, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Watchlist', '${favorites.length}', Icons.bookmark_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Hours Watched', '142 hrs', Icons.timer_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Avg Rating', '8.4 ★', Icons.star_rounded),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // API Integration Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isKeyConfigured
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isKeyConfigured ? AppColors.success : AppColors.glassBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isKeyConfigured ? Icons.key_rounded : Icons.key_off_rounded,
                    color: isKeyConfigured ? AppColors.success : AppColors.secondary,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isKeyConfigured ? 'TMDB API Connected' : 'TMDB API Key (Optional)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isKeyConfigured ? AppColors.success : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isKeyConfigured
                              ? 'Live movie data and images are active.'
                              : 'Edit lib/services/api_constants.dart to insert your TMDB API Key for live updates.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Tile Options
            _buildSettingTile(Icons.dark_mode_rounded, 'Appearance', 'Material 3 Dark Theme Enabled'),
            _buildSettingTile(Icons.notifications_active_rounded, 'Notifications', 'New Releases & Trailers'),
            _buildSettingTile(Icons.download_rounded, 'Offline Downloads', 'High Quality (1080p)'),
            _buildSettingTile(Icons.security_rounded, 'Privacy & Security', 'Manage Account'),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: AppColors.onBackground),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          onTap: () {},
        ),
      ),
    );
  }
}
