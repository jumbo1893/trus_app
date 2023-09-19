import 'package:flutter/material.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';

import '../../../features/general/future_add_controller.dart';
import '../appbar_headline.dart';
import '../listview/listview_add_model.dart';
import '../listview/listview_add_model_double.dart';
import '../loader.dart';

class AddBuilder extends StatelessWidget {
  final FutureAddController addController;
  final String? appBarText;
  final bool? goal;
  final bool? doubleListview;

  const AddBuilder({
    Key? key,
    required this.addController,
    this.appBarText,
    this.goal = false,
    this.doubleListview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    return Scaffold(
      appBar: appBarText != null ? AppBarHeadline(
        text: appBarText!,
      ): null,
      body: Padding(
        padding: const EdgeInsets.only(top: padding),
        child: FutureBuilder<List<AddToString>>(
          future: addController.getModels(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var addToString = snapshot.data![index];
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      left: 8,
                      right: 8,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      child: (doubleListview == null || doubleListview == false) ? ListviewAddModel(
                        padding: 16,
                        addToString: addToString,
                        onNumberAdded: () => addController.addNumber(index, goal?? false),
                        onNumberRemoved: () => addController.removeNumber(index, goal?? false),
                        goal: goal?? false,
                      ) : ListviewAddModelDouble(
                        padding: 16,
                        addToString: addToString,
                        onFirstNumberAdded: () => {addController.addNumber(index, true)},
                        onFirstNumberRemoved: () => {addController.removeNumber(index, true)},
                        onSecondNumberAdded: () => addController.addNumber(index, false),
                        onSecondNumberRemoved: () => addController.removeNumber(index, false),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
