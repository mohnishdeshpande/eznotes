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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verification email has been sent your email address. Please verify.'),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // send verification email
                        context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
                      },
                      child: const Text('Send again'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: const Text('Login'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
