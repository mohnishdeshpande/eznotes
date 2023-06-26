import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final bool emailVerified;

  const AuthUser({required this.emailVerified});

  factory AuthUser.firebase(User user) => AuthUser(emailVerified: user.emailVerified);
}