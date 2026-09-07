import 'package:flutter/material.dart';
import '../navigation_sections.dart';

/// Global navigation belongs to the overview pages. Entry and detail screens
/// retain only their title and return controls, leaving space for local actions.
class NavigationShell extends StatelessWidget {
  final String screenId;
  final String title;
  final Widget? titleWidget;
  final String? teamName;
  final int selectedIndex;
  final VoidCallback onBack, onHome, onAccount, onNotifications;
  final VoidCallback? onAi;
  final ValueChanged<int> onDestination;
  final Widget child;
  const NavigationShell({
    super.key,
    required this.screenId,
    required this.title,
    this.titleWidget,
    this.teamName,
    required this.selectedIndex,
    required this.onBack,
    required this.onHome,
    required this.onAccount,
    this.onAi,
    required this.onNotifications,
    required this.onDestination,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    final isRoot = showsMainNavigation(screenId);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isRoot ? null : BackButton(onPressed: onBack),
        title: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleWidget ??
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (isRoot && teamName != null)
                    Text(
                      teamName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                ],
              ),
            ),
            if (isRoot)
              Container(
                key: const ValueKey('account_divider'),
                width: 1,
                height: 28,
                margin: const EdgeInsets.only(left: 10, right: 4),
                color: Theme.of(context).dividerColor,
              ),
            if (isRoot)
              if (onAi != null)
                IconButton(
                  key: const ValueKey('trusbot_button'),
                  tooltip: 'AI asistent · TrusBot',
                  onPressed: onAi,
                  icon: const Icon(Icons.auto_awesome),
                ),
            if (isRoot)
              IconButton(
                key: const ValueKey('account_button'),
                tooltip: 'Účet a nastavení týmu',
                onPressed: onAccount,
                icon: const Icon(Icons.manage_accounts),
              ),
          ],
        ),
        actions: isRoot
            ? null
            : [
                IconButton(
                  tooltip: 'Zpět na přehled',
                  onPressed: onHome,
                  icon: const Icon(Icons.home_outlined),
                ),
              ],
      ),
      body: child,
      floatingActionButton: isRoot
          ? FloatingActionButton(
              key: const ValueKey('beer_button'),
              tooltip: 'Zapsat piva',
              shape: const CircleBorder(),
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: () => onDestination(2),
              elevation: 5,
              child: const Icon(Icons.sports_bar_outlined, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isRoot
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: 72,
              child: Row(
                children: [
                  _destination(context, 0, Icons.home_outlined, 'Přehled'),
                  _destination(context, 1, Icons.savings_outlined, 'Pokuty'),
                  const SizedBox(
                    width: 64,
                    child: Padding(
                      padding: EdgeInsets.only(top: 36),
                      child: Text(
                        'Piva',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  _destination(context, 3, Icons.bar_chart, 'Statistiky'),
                  _destination(context, 4, Icons.menu, 'Více'),
                ],
              ),
            )
          : null,
    );
  }

  Widget _destination(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) => Expanded(
    child: Semantics(
      selected: selectedIndex == index,
      button: true,
      child: InkWell(
        onTap: () => onDestination(index),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selectedIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selectedIndex == index
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
