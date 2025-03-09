import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:qrphototaker/bloc/CameraBloc.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CameraPage extends StatelessWidget {
  String TAG = "CameraPage MyLog ";

  @override
  Widget build(BuildContext context) {
    final cameraBloc = BlocProvider.of<CameraBloc>(context);
    return Scaffold(
      backgroundColor: Colors.black,
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
                                    print("${TAG}Selected Image Path: ${pickedFile.path}");
                                    final barcodeScanner = BarcodeScanner();
                                    try {
                                      final inputImage = InputImage.fromFilePath(pickedFile.path);
                                      final barcodes = await barcodeScanner.processImage(inputImage);
                                      if (barcodes.isNotEmpty) {
                                        for (Barcode barcode in barcodes) {
                                          print("${TAG}Detected QR Code: ${barcode.rawValue}");
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('QR Code Detected'),
                                              content: GestureDetector(
                                                onTap: () async {
                                                  final url = barcode.rawValue;
                                                  if (url != null) {
                                                    final uri = Uri.parse(url);
                                                    if (await canLaunchUrl(uri)) {
                                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Could not open the link')),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  barcode.rawValue.toString(),
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (barcode.rawValue != null) {
                                                      Share.share(barcode.rawValue.toString());
                                                    }
                                                  },
                                                  child: Text('Share'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } else {
                                        print("${TAG}No QR Code detected.");
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('No QR Code'),
                                            content: Text('No QR Code detected.'),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print("${TAG}Error detecting QR Code: $e");
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Error'),
                                          content: Text('Error detecting QR Code: $e'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
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
                            : GestureDetector(),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RaisedGradientButton(
                          child: Text(
                            'CAPTURE',
                            style: TextStyle(color: Colors.white),
                          ),
                          gradient: LinearGradient(
                            colors: <Color>[Colors.green, Colors.black],
                          ),
                          onPressed: () => cameraBloc.add(TakePhoto()),
                          width: 100,
                          height: 50,
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
                    width: 100,
                    height: 50
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
