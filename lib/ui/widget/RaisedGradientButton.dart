import 'package:flutter/material.dart';

class RaisedGradientButton extends StatefulWidget {
  final String TAG = "RaisedGradientButton MyLog ";
  final Widget child;
  final Gradient? gradient;
  final void Function()? onPressed;

  const RaisedGradientButton({
    required this.child,
    this.gradient,
    this.onPressed,
  });

  @override
  _RaisedGradientButtonState createState() => _RaisedGradientButtonState();
}

class _RaisedGradientButtonState extends State<RaisedGradientButton> {
  final String TAG = "RaisedGradientButtonState MyLog ";
  bool _isPressed = false;
  bool _isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50.0,
      decoration: BoxDecoration(
        gradient: _isPressed
            ? LinearGradient(
          colors: [Colors.red, Colors.orange],
        )
            : _isHovered
            ? LinearGradient(
          colors: [Colors.purple, Colors.pink], // Hovered gradient
        )
            : LinearGradient(
          colors: [Colors.blue, Colors.green], // Normal state gradient
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.5),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print(TAG + "onTap");
            setState(() {
              _isPressed = true;
            });
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                _isPressed = false;
              });
            });
          },
          // Disable the splash and highlight colors
          splashColor: Colors.transparent, // No splash effect
          highlightColor: Colors.transparent, // No highlight effect
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
