import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // passing auth provider to bloc, default state loading
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialised(isLoading: true)) {
    // here we handle the events and produce states

    // initialise
    on<AuthEventInitialise>(
      (event, emit) async {
        await provider.initialise();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else if (!user.emailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      },
    );

    // log in
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Loggin in...',
        ));
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );

          if (!user.emailVerified) {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            // diable loading screen
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          }

          emit(AuthStateLoggedIn(user: user, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    // log out
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    // email verification
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    //register
    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      },
    );

    on<AuthEventShouldRegister>(
      (event, emit) {
        emit(const AuthStateRegistering(exception: null, isLoading: false));
      },
    );
  }
}
