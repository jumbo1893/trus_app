String normalizeSearchText(String value) {
  const replacements = <String, String>{
    'á': 'a',
    'č': 'c',
    'ď': 'd',
    'é': 'e',
    'ě': 'e',
    'í': 'i',
    'ň': 'n',
    'ó': 'o',
    'ř': 'r',
    'š': 's',
    'ť': 't',
    'ú': 'u',
    'ů': 'u',
    'ý': 'y',
    'ž': 'z',
  };

  final lowerCase = value.toLowerCase().trim();
  final result = StringBuffer();
  for (final character in lowerCase.split('')) {
    result.write(replacements[character] ?? character);
  }
  return result.toString();
}
