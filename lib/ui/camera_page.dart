import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrphototaker/bloc/camera_bloc.dart';
import 'dart:io';

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cameraBloc = BlocProvider.of<CameraBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Take Photo')),
      body: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          if (state is CameraInitial) {
            cameraBloc.add(InitializeCamera());
            return Center(child: CircularProgressIndicator());
          } else if (state is CameraInitialized) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: CameraPreview(state.controller),
                  ),
                ),
                SizedBox(height: 20),
                RaisedGradientButton(
                    child: Text(
                      'Capture',
                      style: TextStyle(color: Colors.white),
                    ),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.green, Colors.black],
                    ),
                    onPressed: () => cameraBloc.add(TakePhoto())),
              ],
            );
          } else if (state is PhotoCaptured) {
            return Column(
              children: [
                Expanded(
                  child: Center(child: Image.file(File(state.photo.path))),
                ),
                _CustomElevatedButton(
                  onPressed: () => cameraBloc.add(InitializeCamera()),
                  label: 'Retake',
                ),
              ],
            );
          }
          return Center(child: Text('Unknown State'));
        },
      ),
    );
  }
}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient? gradient; // Nullable gradient
  final void Function()? onPressed; // Nullable onPressed callback

  const RaisedGradientButton({
    required this.child,
    this.gradient,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50.0,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: [Colors.blue, Colors.green], // Default gradient
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue,
            offset: Offset(0.0, 1.5),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CustomElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _CustomElevatedButton({Key? key, required this.onPressed, required this.label}) : super(key: key);

  @override
  _CustomElevatedButtonState createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<_CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.blueAccent; // Color when pressed
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.lightBlueAccent; // Color when hovered
          } else {
            return Colors.blue; // Default color
          }
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Padding inside the button
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Rounded corners to match the button
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Text(
          widget.label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
