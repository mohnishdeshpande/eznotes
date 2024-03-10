import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/themes/theme.dart';
import 'package:mynotes/utils/dialogs/error_dialog.dart';
import 'package:mynotes/utils/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _textController;
  AuthProvider provider = FirebaseAuthProvider();

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<bool> sendResetLink(String email) async {
    bool res = true;
    try {
      await provider.sendPasswordReset(email: email);
    } on Exception catch (_) {
      res = false;
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter email to send password reset link',
                style: MyTheme.myTextStyle(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  // helperText: '',
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Login'),
                  )
                ],
              ),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final email = _textController.text;
                        _textController.clear();
                        // reset process
                        bool linkSent = await sendResetLink(email);
                        if (linkSent && context.mounted) {
                          await showPasswordResetEmailSentDialog(context);
                        } else {
                          if (context.mounted) {
                            await showErrorDialog(context, 'Unable to process');
                          }
                        }
                      },
                      child: const Text('Send reset link'),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {

                    //   },
                    //   child: const Text('Back to Login'),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    // return BlocListener<AuthBloc, AuthState>(
    //   listener: (context, state) async {
    //     if (state is AuthStateForgotPassword) {
    //       if (state.emailSent) {
    //         _textController.clear();
    //         await showPasswordResetEmailSentDialog(context);
    //       }
    //       if (state.exception != null) {
    //         if (context.mounted) {
    //           await showErrorDialog(context, 'Reset request failed.');
    //         }
    //       }
    //     }
    //   },
    //   child: ,
    // );
  }
}
