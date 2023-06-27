import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final bool emailVerified;
  final String? email;

  const AuthUser({required this.emailVerified, required this.email});

  factory AuthUser.firebase(User user) => AuthUser(
        emailVerified: user.emailVerified,
        email: user.email,
      );
}
