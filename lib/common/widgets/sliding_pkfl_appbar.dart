import 'package:flutter/material.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';

class SlidingPkflAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SlidingPkflAppBar({
    super.key,
    required this.pkflMatch,
    required this.onConfirmPressed,
    required this.onAppBarInvisible,
  });

  final VoidCallback onConfirmPressed;
  final PkflMatch? pkflMatch;
  final VoidCallback onAppBarInvisible;

  @override
  State<SlidingPkflAppBar> createState() => _SlidingPkflAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);
}

class _SlidingPkflAppBarState extends State<SlidingPkflAppBar>
    with SingleTickerProviderStateMixin {
  bool visible = true;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void hideAppBar() {
    setState(() {
      visible = !visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pkflMatch == null) {
      visible = false;
      widget.onAppBarInvisible();
    }
    visible ? _animationController.reverse() : _animationController.forward();
    return SlideTransition(
        position:
            Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.fastOutSlowIn)
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                widget.onAppBarInvisible();
              }
            }),
        ),
        child: AppBar(
            title: widget.pkflMatch != null ? Text(
              widget.pkflMatch!.date.isBefore(DateTime.now()) ?
                "Načíst poslední zápas\n${widget.pkflMatch!.toStringNameWithOpponent()}?" : "Načíst příští zápas\n${widget.pkflMatch?.toStringNameWithOpponent()}?",
                style: const TextStyle(fontSize: 13)) : const Text(""),
            actions: [
              IconButton(
                  onPressed: () => {hideAppBar(), widget.onConfirmPressed()},
                  icon: const Icon(Icons.check)),
              IconButton(
                  onPressed: () => hideAppBar(), icon: const Icon(Icons.close)),
            ],
            centerTitle: false,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white));
  }
}
