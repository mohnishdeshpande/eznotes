import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/firebase_options.dart';

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
          // initialise firebase before building/redering the column
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
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
                      child: const Text('Register'),
                      onPressed: () async {
                        //extracting text from the controllers
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          // registering with the user credentials
                          final userCred = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(email: email, password: password);

                          // print the response from firebase
                          print(userCred);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'invalid-email') {
                            print('Invalid email');
                          } else if (e.code == 'email-already-in-use') {
                            print('Email already in use');
                          } else if (e.code == 'weak-password') {
                            print('Weak password');
                          }
                        }
                      },
                    ),
                  ],
                );
              default:
                return const Text('Loading');
            }
          },
        ));
  }
}