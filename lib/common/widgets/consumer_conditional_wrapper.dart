import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsumerConditionalWrapper extends ConsumerWidget {
  final Widget Function(BuildContext context) builder;
  final bool Function(WidgetRef ref) condition;

  const ConsumerConditionalWrapper({
    Key? key,
    required this.builder,
    required this.condition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return condition(ref) ? builder(context) : const SizedBox.shrink();
  }
}
