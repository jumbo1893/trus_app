import 'package:flutter/material.dart';
import 'package:trus_app/features/main/menu/widget/animated_menu_extension.dart';
import 'package:trus_app/features/main/menu/widget/fade_slide_in.dart';
import 'package:trus_app/theme/app_colors.dart';

class AppMenuBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleBadge;
  final Widget? trailing;
  final List<Widget> children;
  final double heightFactor;
  final EdgeInsets contentPadding;
  final bool useListView;

  const AppMenuBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.titleBadge,
    this.trailing,
    required this.children,
    this.heightFactor = 0.78,
    this.contentPadding = const EdgeInsets.only(bottom: 20, top: 6),
    this.useListView = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required List<Widget> children,
    String? title,
    String? subtitle,
    Widget? titleBadge,
    Widget? trailing,
    double heightFactor = 0.78,
    EdgeInsets contentPadding = const EdgeInsets.only(bottom: 20, top: 6),
    bool useListView = false,
  }) {
    final appColors = context.appColors;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) {
        return AppMenuBottomSheet(
          title: title,
          subtitle: subtitle,
          titleBadge: titleBadge,
          trailing: trailing,
          heightFactor: heightFactor,
          contentPadding: contentPadding,
          useListView: useListView,
          children: children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SizedBox(
      height: MediaQuery.of(context).size.height * heightFactor,
      child: Column(
        children: [
          FadeSlideIn(
            duration: const Duration(milliseconds: 250),
            beginOffset: const Offset(0, 0.04),
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: appColors.textSecondary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),

          if (title != null || subtitle != null || trailing != null)
            FadeSlideIn(
              duration: const Duration(milliseconds: 320),
              delay: const Duration(milliseconds: 40),
              beginOffset: const Offset(0, 0.05),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: subtitle == null ? 13 : 20,
                                      fontWeight: subtitle == null
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                      color: appColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (titleBadge != null) titleBadge!,
                              ],
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 13,
                                color: appColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            ),

          Divider(
            height: 1,
            color: appColors.textSecondary.withValues(alpha: 0.15),
          ),

          Expanded(
            child: useListView
                ? ListView(
                    padding: contentPadding,
                    children: [
                      ...children,
                      const SizedBox(height: 30),
                    ].withStaggeredAnimation(),
                  )
                : SingleChildScrollView(
                    padding: contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...children,
                        const SizedBox(height: 30),
                      ].withStaggeredAnimation(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
