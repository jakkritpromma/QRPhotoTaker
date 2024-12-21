import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrphototaker/bloc/camera_bloc.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'package:qrphototaker/ui/widget/CustomElevatedButton.dart';
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
                CustomElevatedButton(
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

