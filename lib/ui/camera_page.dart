import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrphototaker/bloc/camera_bloc.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'dart:io';

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cameraBloc = BlocProvider.of<CameraBloc>(context);
    return Scaffold(
      appBar: null, // Hides the default AppBar
      body: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          if (state is CameraInitial) {
            cameraBloc.add(InitializeCamera());
            return Center(child: CircularProgressIndicator());
          } else if (state is CameraInitialized) {
            return Stack(
              children: [
                // CameraPreview in the background
                Positioned.fill(
                  child: CameraPreview(state.controller),
                ),
                // Positioned back button in the foreground
                Positioned(
                  top: 30, // Position the button 30 pixels from the top
                  left: 10, // Position from the left side
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous page
                    },
                  ),
                ),
                // RaisedGradientButton in the foreground, positioned at the bottom
                Positioned(
                  bottom: 30, // Position the button 30 pixels from the bottom
                  left: 20, // Optionally adjust left and right
                  right: 20,
                  child: RaisedGradientButton(
                    child: Text(
                      'Capture',
                      style: TextStyle(color: Colors.white),
                    ),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.green, Colors.black],
                    ),
                    onPressed: () => cameraBloc.add(TakePhoto()),
                  ),
                ),
              ],
            );
          } else if (state is PhotoCaptured) {
            return Stack(
              children: [
                // Display the captured image in the background
                Positioned.fill(
                  child: Center(
                    child: Image.file(File(state.photo.path)),
                  ),
                ),
                // Positioned back button in the foreground
                Positioned(
                  top: 30, // Position the button 30 pixels from the top
                  left: 10, // Position from the left side
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous page
                    },
                  ),
                ),
                // RaisedGradientButton in the foreground, positioned at the bottom
                Positioned(
                  bottom: 30, // Position the button 30 pixels from the bottom
                  left: 20, // Optionally adjust left and right
                  right: 20,
                  child: RaisedGradientButton(
                    child: Text(
                      'Retake',
                      style: TextStyle(color: Colors.white),
                    ),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.green, Colors.black],
                    ),
                    onPressed: () => cameraBloc.add(InitializeCamera()),
                  ),
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
