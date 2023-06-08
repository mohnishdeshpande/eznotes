import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'views/register_view.dart';
import 'views/login_view.dart';

void main() {
  // LEARN MORE ABOUT THIS
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      // useMaterial3: true,
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          // backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
          // initialise firebase before building/redering the column
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                // if email verified
                if (user?.emailVerified ?? false) {
                  return const Text('Email verfied');
                } else {
                  return const VerifyEmailView();
                }
              default:
                return const Text('Loading');
            }
          },
        ));
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Please verify your email'),
        TextButton(
          onPressed: () async {
            // get current user
            final user = FirebaseAuth.instance.currentUser;
            // send verification email
            await user?.sendEmailVerification();
          },
          child: const Text('Send Email'),
        )
      ],
    );
  }
}
