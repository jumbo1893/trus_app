class LoginException implements Exception {
  String cause;

  LoginException([this.cause = 'Nelze načíst data z důvodu chyby na straně serveru']);

  @override
  String toString() {
    return cause;
  }
}