import 'package:flutter/material.dart';
import '../models/cast_member.dart';
import '../models/actor.dart';
import '../theme/app_colors.dart';
import 'safe_network_image.dart';

class ActorCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? profileUrl;
  final VoidCallback onTap;
  final double radius;

  const ActorCard({
    super.key,
    required this.name,
    this.subtitle,
    this.profileUrl,
    required this.onTap,
    this.radius = 38,
  });

  factory ActorCard.fromCastMember(CastMember cast, {required VoidCallback onTap}) {
    return ActorCard(
      name: cast.name,
      subtitle: cast.character,
      profileUrl: cast.fullProfileUrl,
      onTap: onTap,
    );
  }

  factory ActorCard.fromActor(Actor actor, {required VoidCallback onTap}) {
    return ActorCard(
      name: actor.name,
      subtitle: actor.knownForDepartment,
      profileUrl: actor.fullProfileUrl,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: AppColors.surfaceContainer,
                child: ClipOval(
                  child: SafeNetworkImage(
                    imageUrl: profileUrl ?? '',
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    title: name,
                    icon: Icons.person_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
