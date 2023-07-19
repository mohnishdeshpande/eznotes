import 'package:mynotes/services/auth/auth_user.dart';

// interface for all authentication functionalities
abstract class AuthProvider {
  Future<void> initialise();

  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordReset({required String email});
}
