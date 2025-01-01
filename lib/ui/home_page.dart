import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'package:qrphototaker/ui/camera_page.dart';
import 'package:qrphototaker/ui/qr_scanner_page.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({required this.cameras});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = screenWidth / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera & QR Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RaisedGradientButton 1
              RaisedGradientButton(
                child: Text(
                  'TAKE PHOTO',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
                gradient: LinearGradient(
                  colors: <Color>[Colors.green, Colors.black],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                ),
                borderRadius: 12.0,
                width: screenWidth,
                height: buttonHeight,
              ),
              SizedBox(height: 20),
              // RaisedGradientButton 2
              RaisedGradientButton(
                child: Text(
                  'SCAN QR CODE',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
                gradient: LinearGradient(
                  colors: <Color>[Colors.green, Colors.black],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerPage()),
                ),
                borderRadius: 12.0,
                width: screenWidth,
                height: buttonHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
