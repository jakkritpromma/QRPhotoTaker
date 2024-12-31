import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:qrphototaker/bloc/camera_bloc.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatelessWidget {
  String TAG = "CameraPage MyLog ";

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
                        child: state.latestPhoto != null
                            ? FutureBuilder<Uint8List?>(
                          future: state.latestPhoto!.thumbnailDataWithSize(ThumbnailSize(50, 50)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    print("Selected Image Path: ${pickedFile.path}");
                                    final barcodeScanner = BarcodeScanner();
                                    try {
                                      final inputImage = InputImage.fromFilePath(pickedFile.path);
                                      final barcodes = await barcodeScanner.processImage(inputImage);
                                      if (barcodes.isNotEmpty) {
                                        for (Barcode barcode in barcodes) {
                                          print('Detected QR Code: ${barcode.rawValue}');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('QR Code: ${barcode.rawValue}')),
                                          );
                                        }
                                      } else {
                                        print('No QR Code detected.');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('No QR Code detected')),
                                        );
                                      }
                                    } catch (e) {
                                      print('Error detecting QR Code: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error detecting QR Code')),
                                      );
                                    } finally {
                                      barcodeScanner.close();
                                    }
                                  }
                                },
                                child: Center(
                                  child: ClipOval(
                                    child: Image.memory(
                                      snapshot.data!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error loading photo');
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        )
                            : GestureDetector(
                        ),
                      ),
                      SizedBox(width: 10),
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
