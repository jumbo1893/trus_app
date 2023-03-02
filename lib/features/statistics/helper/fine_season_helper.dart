import 'package:trus_app/models/season_model.dart';

import '../../../models/enum/fine.dart';

class FineSeasonHelper {
  int fineNumber;
  int fineAmount;
  int matchNumber;
  final SeasonModel seasonModel;

  FineSeasonHelper({required this.seasonModel, this.fineNumber = 0, this.fineAmount = 0, this.matchNumber = 0});

  void addFine(int fineNumber) {
    this.fineNumber += fineNumber;
  }

  void addFineAmount(int fineAmount) {
    this.fineAmount += fineAmount;
  }

  void addMatch() {
    matchNumber++;
  }

  int getNumberOrAmount(Fine fine) {
    if(fine == Fine.number) {
      return fineNumber;
    }
    return fineAmount;
  }
}