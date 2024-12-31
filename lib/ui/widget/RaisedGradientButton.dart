import 'package:flutter/material.dart';

class RaisedGradientButton extends StatefulWidget {
  final String TAG = "RaisedGradientButton MyLog ";
  final Widget child;
  final Gradient? gradient;
  final void Function()? onPressed;
  final void Function()? onLongPressed;
  final double borderRadius; // Add a property for border radius
  final double width; // Dynamically pass the width
  final double height; // Dynamically pass the height

  const RaisedGradientButton({
    required this.child,
    this.gradient,
    this.onPressed,
    this.onLongPressed,
    this.borderRadius = 12.0, // Default radius value is 12
    required this.width, // Dynamically pass width
    required this.height, // Dynamically pass height
  });

  @override
  _RaisedGradientButtonState createState() => _RaisedGradientButtonState();
}

class _RaisedGradientButtonState extends State<RaisedGradientButton> {
  final String TAG = "RaisedGradientButtonState MyLog ";
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,  // Use passed width
      height: widget.height, // Use passed height
      decoration: BoxDecoration(
        gradient: _isPressed
            ? LinearGradient(
          colors: [Colors.red, Colors.orange],
        )
            : LinearGradient(
          colors: [Colors.blue, Colors.green],
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius), // Apply rounded corners
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
        child: GestureDetector(
          onLongPress: () {
            print(TAG + "onLongPress");
            setState(() {
              _isPressed = true;
            });
          },
          onLongPressEnd: (details) {
            print(TAG + "onLongPressEnd");
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
            setState(() {
              _isPressed = false;
            });
          },
          onTap: () {
            print(TAG + "onTap");
            setState(() {
              _isPressed = true;
            });
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
            Future.delayed(Duration(milliseconds: 250), () {
              setState(() {
                _isPressed = false;
              });
            });
          },
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Center(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
