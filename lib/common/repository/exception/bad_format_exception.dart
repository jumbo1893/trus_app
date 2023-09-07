
class BadFormatException implements Exception {
  String cause;

  BadFormatException([this.cause = 'Nelze načíst všechna pole z webu pkfl, neproběhl redesign webu? Kontaktuj tvůrce appky']);

  @override
  String toString() {
    return cause;
  }
}