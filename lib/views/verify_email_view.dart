import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final authService = AuthService.firebase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Text('We\'ve sent a verification email. Please verify.'),
          const Text('Not received yet?'),
          TextButton(
            onPressed: () async {
              // send verification email
              await authService.sendEmailVerification();
            },
            child: const Text('Send again'),
          ),
          TextButton(
            onPressed: () async {
              await authService.logOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              }
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
