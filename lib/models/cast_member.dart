import '../services/api_constants.dart';

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.order = 0,
  });

  String get fullProfileUrl => ApiConstants.getProfileUrl(profilePath);

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown Actor',
      character: json['character'] ?? 'Role Unspecified',
      profilePath: json['profile_path'] ?? json['profilePath'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_path': profilePath,
      'order': order,
    };
  }
}
