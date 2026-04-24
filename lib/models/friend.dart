class Friend {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;

  Friend({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}
