
import '../../enum/spinner_options.dart';

abstract class FootballIndividualStatsToString {
  String toStringForListView(SpinnerOption option);
  String listViewTitle();
}