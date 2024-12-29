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
      appBar: null, // Hide the default AppBar.
      body: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          if (state is CameraInitial) {
            cameraBloc.add(InitializeCamera());
            return Center(child: CircularProgressIndicator());
          } else if (state is CameraInitialized) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(state.controller),
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous page
                    },
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                      SizedBox(width: 10),
                      Expanded(
                        child: RaisedGradientButton(
                          child: Text(
                            'Capture2',
                            style: TextStyle(color: Colors.white),
                          ),
                          gradient: LinearGradient(
                            colors: <Color>[Colors.green, Colors.black],
                          ),
                          onPressed: () => cameraBloc.add(TakePhoto()),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is PhotoCaptured) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Image.file(File(state.photo.path)),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous page
                    },
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
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
