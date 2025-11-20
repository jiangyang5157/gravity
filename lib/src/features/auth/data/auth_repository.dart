import 'package:gravity/src/features/auth/domain/user.dart';

abstract class AuthRepository {
  Future<User?> login(String username, String password);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<User?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (username == 'admin' && password.isEmpty) {
      return const User(id: '1', username: 'Admin User', role: UserRole.admin);
    }

    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
