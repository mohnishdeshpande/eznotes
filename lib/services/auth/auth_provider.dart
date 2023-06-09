import 'package:mynotes/services/auth/auth_user.dart';

// interface for all authentication functionalities
abstract class AuthProvider {
  // a getter for current user
  AuthUser? get currentUser;

  // a login method, that is a future
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  // create user
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  // log out
  Future<void> logOut();

  // email verification
  Future<void> sendEmailVerification();
}
