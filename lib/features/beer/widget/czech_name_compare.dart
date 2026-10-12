const _alphabet = <String>[
  'a',
  'á',
  'b',
  'c',
  'č',
  'd',
  'ď',
  'e',
  'é',
  'ě',
  'f',
  'g',
  'h',
  'ch',
  'i',
  'í',
  'j',
  'k',
  'l',
  'm',
  'n',
  'ň',
  'o',
  'ó',
  'p',
  'q',
  'r',
  'ř',
  's',
  'š',
  't',
  'ť',
  'u',
  'ú',
  'ů',
  'v',
  'w',
  'x',
  'y',
  'ý',
  'z',
  'ž',
];

final _weights = <String, int>{
  for (var i = 0; i < _alphabet.length; i++) _alphabet[i]: i,
};

List<int> _czechSortKey(String name) {
  final lower = name.trim().toLowerCase();
  final key = <int>[];
  for (var i = 0; i < lower.length; i++) {
    if (i + 1 < lower.length && lower.substring(i, i + 2) == 'ch') {
      key.add(_weights['ch']!);
      i++;
    } else {
      final letter = lower[i];
      key.add(
        _weights[letter] ?? (letter == ' ' ? -1 : 1000 + letter.codeUnitAt(0)),
      );
    }
  }
  return key;
}

int compareCzechNames(String a, String b) {
  final left = _czechSortKey(a);
  final right = _czechSortKey(b);
  for (var i = 0; i < left.length && i < right.length; i++) {
    final comparison = left[i].compareTo(right[i]);
    if (comparison != 0) return comparison;
  }
  return left.length.compareTo(right.length);
}
