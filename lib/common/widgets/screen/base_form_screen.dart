import 'package:flutter/material.dart';

import '../bar/action_button_item.dart';
import '../bar/form_action_bar_horizontal.dart';
import '../header/header_card.dart';
import '../rows/form/form_card.dart';
import '../../../theme/app_widget_values.dart';

class BaseFormScreen extends StatelessWidget {
  final String headerTitle;
  final String headerText;
  final List<Widget> fields;
  final List<ActionButtonItem> actions;
  final List<Widget> extraSections;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;
  final bool useSafeArea;
  final Widget? floatingActionButton;

  const BaseFormScreen({
    super.key,
    required this.headerTitle,
    required this.headerText,
    required this.fields,
    required this.actions,
    this.extraSections = const [],
    this.scrollController,
    this.padding = const EdgeInsets.only(bottom: 100),
    this.useSafeArea = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      controller: scrollController,
      padding: padding,
      children: [
        AppWidgetValues.field,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HeaderCard(
            title: headerTitle,
            text: headerText,
          ),
        ),
        AppWidgetValues.field,
        FormCard(
          children: fields,
        ),
        ...extraSections,
      ],
    );

    return Scaffold(
      body: useSafeArea ? SafeArea(child: content) : content,
      bottomNavigationBar: actions.isEmpty
          ? null
          : Padding(
        padding: const EdgeInsets.only(bottom: 18),
            child: FormActionBarHorizontal(actions: actions),
          ),
      floatingActionButton: floatingActionButton,
    );
  }
}