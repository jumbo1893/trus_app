import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/fine_api_model.dart';

void main() {
  test('parses code and editability from the new backend response', () {
    final fine = FineApiModel.fromJson({
      'id': 24,
      'name': 'Třetí poločas',
      'amount': 150,
      'inactive': false,
      'code': 'THIRD_HALF',
      'editable': false,
    });

    expect(fine.code, 'THIRD_HALF');
    expect(fine.editable, isFalse);
    expect(fine.toJson()['code'], 'THIRD_HALF');
  });

  test('stays compatible with backend responses without the new fields', () {
    final fine = FineApiModel.fromJson({
      'id': 99,
      'name': 'Vlastní pokuta',
      'amount': 50,
      'inactive': false,
    });

    expect(fine.code, isNull);
    expect(fine.editable, isTrue);
  });
}
