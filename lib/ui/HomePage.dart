import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qrphototaker/ui/ConversionPage.dart';
import 'package:qrphototaker/ui/widget/RaisedGradientButton.dart';
import 'package:qrphototaker/ui/CameraPage.dart';
import 'package:qrphototaker/ui/QrScannerPage.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({required this.cameras});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = screenHeight * 0.2; // 20% of screen height

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & QR Scanner'),
      ),
      body: SingleChildScrollView(  // Ensure content can scroll if needed
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center,  // Center horizontally
            children: [
              //SizedBox(height: screenHeight * 0.15),  // Add space from the top (optional)

              // RaisedGradientButton 1
              RaisedGradientButton(
                gradient: const LinearGradient(
                  colors: <Color>[Colors.green, Colors.black],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                ),
                borderRadius: 12.0,
                width: screenWidth * 0.8,  // Adjust width to prevent stretching
                height: buttonHeight,
                child: const Text(
                  'TAKE PHOTO',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
              const SizedBox(height: 20),
              // RaisedGradientButton 2
              RaisedGradientButton(
                gradient: const LinearGradient(
                  colors: <Color>[Colors.green, Colors.black],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerPage()),
                ),
                borderRadius: 12.0,
                width: screenWidth * 0.8,  // Adjust width to prevent stretching
                height: buttonHeight,
                child: const Text(
                  'SCAN QR CODE',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
              const SizedBox(height: 20),
              RaisedGradientButton(
                gradient: const LinearGradient(
                  colors: <Color>[Colors.green, Colors.black],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversionPage()),
                ),
                borderRadius: 12.0,
                width: screenWidth * 0.8,  // Adjust width to prevent stretching
                height: buttonHeight,
                child: const Text(
                  'ENERGY MASS CONVERT',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
              SizedBox(height: screenHeight * 0.15),  // Add space from the bottom (optional)
            ],
          ),
        ),
      ),
    );
  }
}
