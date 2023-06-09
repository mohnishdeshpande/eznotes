import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utils/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // text fields controller
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // assigning the controllers as promised
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.firebase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // email text field
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
          ),
          // password text field
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          // register button
          TextButton(
            child: const Text('Register'),
            onPressed: () async {
              //extracting text from the controllers
              final email = _email.text;
              final password = _password.text;
              try {
                // registering with the user credentials
                await authService.createUser(email: email, password: password);

                // send verification email
                authService.sendEmailVerification();

                // continue to verify email
                if (context.mounted) {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Invalid Email');
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'Email already in use');
              } on WeakPasswordAuthException {
                await showErrorDialog(context, 'Weak Password');
              } on GenericAuthException {
                await showErrorDialog(context, 'Registration failed');
              }
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already Registered? Login here'),
          ),
        ],
      ),
    );
  }
}
