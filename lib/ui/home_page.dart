import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'package:qrphototaker/ui/widget/CustomElevatedButton.dart';
import 'package:qrphototaker/ui/camera_page.dart';
import 'package:qrphototaker/ui/qr_scanner_page.dart';

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
