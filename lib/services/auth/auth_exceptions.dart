// login excpetions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register excpetions
class InvalidEmailAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

// generic excpetions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
