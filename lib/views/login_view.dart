import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/constants/routes.dart';

import 'package:mynotes/utils/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          TextButton(
            child: const Text('Login'),
            onPressed: () async {
              //extracting text from the controllers
              final email = _email.text;
              final password = _password.text;
              try {
                // registering with the user credentials
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: email, password: password);

                // navigate to the Main UI
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    'notesRoute',
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  await showErrorDialog(context, 'User not found');
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(context, 'Wrong password');
                } else {
                  await showErrorDialog(context, e.code.toString());
                }
              } catch (e) {
                await showErrorDialog(context, e.runtimeType.toString());
              }
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Register here'),
          ),
        ],
      ),
    );
  }
}
