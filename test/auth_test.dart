import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    // creating instance of the mock provider
    final provider = MockAuthProvider();

    test('Should not be initialised to begin with', () {
      expect(provider.isInitialised, false);
    });

    test('Should not logout if not initialised', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitialisedException>()),
      );
    });

    test('Should be able to initialise', () async {
      await provider.initialise();
      expect(provider.isInitialised, true);
    });

    test('User should be null upon initialisation', () {
      expect(provider.currentUser, null);
    });

    test('Initialise in under 2 seconds', () async {
      await provider.initialise();
      expect(provider.isInitialised, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user delegating to log in', () async {
      final badEmailUser = provider.createUser(
        email: 'bad@xyz.com',
        password: 'pwdpwd',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final goodEmailUser = await provider.createUser(
        email: 'good@xyz.com',
        password: 'pwdpwd',
      );
      expect(provider.currentUser, goodEmailUser);
      expect(goodEmailUser.emailVerified, false);
    });

    test('Logged in user should be able to verify email', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.emailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'pasword');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitialisedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  // auxiliary test variables
  AuthUser? _user;
  var _isInitialised = false;
  bool get isInitialised => _isInitialised;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialised) throw NotInitialisedException();
    await Future.delayed(const Duration(seconds: 1));

    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialise() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialised = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialised) throw NotInitialisedException();
    if (email == 'bad@xyz.com') throw UserNotFoundAuthException();
    const user = AuthUser(emailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialised) throw NotInitialisedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialised) throw NotInitialisedException();
    if (_user == null) throw UserNotFoundAuthException();
    _user = const AuthUser(emailVerified: true);
  }
}
