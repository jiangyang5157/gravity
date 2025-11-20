import 'package:gravity/src/features/auth/data/auth_repository.dart';
import 'package:gravity/src/features/auth/domain/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return MockAuthRepository();
}

@riverpod
class AuthController extends _$AuthController {
  @override
  User? build() {
    return null;
  }

  Future<bool> login(String username, String password) async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.login(username, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = null;
  }
}
