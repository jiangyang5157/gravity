enum UserRole { admin, customer }

class User {
  final String id;
  final String username;
  final UserRole role;

  const User({required this.id, required this.username, required this.role});

  bool get isAdmin => role == UserRole.admin;
}
