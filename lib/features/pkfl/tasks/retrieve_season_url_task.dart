import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/models/pkfl/pkfl_season.dart';
import '../../general/repository/request_executor.dart';

class RetrieveSeasonUrlTask extends RequestExecutor {
  final String pkflUrl;
  final bool currentSeason;
  static const String baseUrl = "https://pkfl.cz";

  RetrieveSeasonUrlTask(this.pkflUrl, this.currentSeason);

  Future<List<PkflSeason>> returnPkflSeasons() async {
    Response response = await getDioClient().get(pkflUrl);
    List<PkflSeason> pkflSeasons = [];
    validatePkflStatusCode(response.statusCode);
    try {
      var document = parse(response.data);
      var matchesSpinnerDiv = document.getElementsByClassName(
          "dropdown-content")[0];
      var spinnerSeasons = matchesSpinnerDiv.querySelectorAll("a[href]");
      if(currentSeason) {
        for (var spinnerButton in spinnerSeasons) {
          var seasonButton = document.getElementsByClassName("dropbtn")[0];
          if(spinnerButton.text.contains(_getCurrentSeason(seasonButton))) {
            pkflSeasons.add(_returnPkflSeason(spinnerButton));
          }
        }
      }
      else {
        for (Element spinnerButton in spinnerSeasons) {
          pkflSeasons.add(_returnPkflSeason(spinnerButton));
        }
      }
      return pkflSeasons;
    } on BadFormatException {
      rethrow;
    } catch (e, stacktrace) {
      print(stacktrace);
      throw BadFormatException();
    }
  }

  String _getCurrentSeason(Element button) {
    return button.text.split(" ")[0].trim().toLowerCase();
  }

  PkflSeason _returnPkflSeason(Element spinnerButton) {
      return PkflSeason(baseUrl + spinnerButton.attributes['href'].toString(), spinnerButton.text);
  }
}
