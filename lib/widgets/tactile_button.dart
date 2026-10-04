import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

/// A Neo-Brutalist button with hard drop shadow that animates to a pressed state
/// on tap — shadow shrinks from 4px to 1px and the button translates 3px.
class TactileButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final BoxShadow restingShadow;

  const TactileButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color = NB.cardWhite,
    this.radius = NB.pillRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    this.restingShadow = NB.shadowCompact,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeInOut,
        transform: _pressed
            ? Matrix4.translationValues(3.0, 3.0, 0.0)
            : Matrix4.identity(),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: NB.borderBlack, width: NB.strokeWidth),
          boxShadow: [_pressed ? NB.shadowPressed : widget.restingShadow],
        ),
        child: widget.child,
      ),
    );
  }
}
