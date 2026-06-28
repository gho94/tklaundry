import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_api.dart';
import '../domain/auth_user.dart';

class AuthNotifier extends Notifier<AuthUser?> {
  late final AuthApi _authApi;

  @override
  AuthUser? build() {
    _authApi = AuthApi();
    return null;
  }

  Future<void> login({
    required String userId,
    required String password,
  }) async {
    state = await _authApi.login(userId: userId, password: password);
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);
