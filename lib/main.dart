import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrphototaker/bloc/qr_scanner_bloc.dart';
import 'package:qrphototaker/bloc/camera_bloc.dart';
import 'package:qrphototaker/ui/camera_page.dart';
import 'package:qrphototaker/ui/qr_scanner_page.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'package:qrphototaker/ui/widget/CustomElevatedButton.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CameraBloc(cameras)),
        BlocProvider(create: (_) => QRScannerBloc()),
      ],
      child: MyApp(
        cameras: [],
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera & QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(cameras: cameras),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera & QR Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraPage(),
                ),
              ),
              label: 'Take Photo',
            ),
            SizedBox(height: 20),
            RaisedGradientButton(
                child: Text(
                  'Scan QR Code',
                  style: TextStyle(color: Colors.white),
                ),
                gradient: LinearGradient(
                  colors: <Color>[Colors.green, Colors.black],
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerPage()))),
          ],
        ),
      ),
    );
  }
}
