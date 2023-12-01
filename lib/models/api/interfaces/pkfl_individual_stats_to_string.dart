
import '../../enum/spinner_options.dart';

abstract class PkflIndividualStatsToString {
  String toStringForListView(SpinnerOption option);
  String listViewTitle();
}