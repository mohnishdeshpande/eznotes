import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool emailVerified;

  const AuthUser({
    required this.id,
    required this.emailVerified,
    required this.email,
  });

  factory AuthUser.firebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        emailVerified: user.emailVerified,
      );
}
