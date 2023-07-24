import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('We\'ve sent a verification email. Please verify.'),
            const Text('Not received yet?'),
            TextButton(
              onPressed: () {
                // send verification email
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
              },
              child: const Text('Send again'),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text('Restart'),
            )
          ],
        ),
      ),
    );
  }
}
