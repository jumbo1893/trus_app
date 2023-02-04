class PercentageLoaderModel {
  double percentage = 0;
  final String text;
  static const numberOfMatchesInSeason = 11;

  PercentageLoaderModel(this.text);

  void calculatePercentageNumber(int matchNumber, int numberOfSeasons) {
    double percentage = matchNumber/(numberOfSeasons*numberOfMatchesInSeason);
    if(percentage > 1.0) {
      this.percentage = 1.0;
    }
    else {
      this.percentage = percentage;
    }
  }
}