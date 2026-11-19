enum AuthFailure { phoneExists, wrongCredentials }

class AuthException implements Exception {
  const AuthException(this.type);
  final AuthFailure type;
}
