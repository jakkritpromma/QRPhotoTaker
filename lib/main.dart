import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
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
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraPage(cameras: cameras),
                ),
              ),
              child: Text('Take Photo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerPage(),
                ),
              ),
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _image = image;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Photo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_image != null) ...[
            Image.file(File(_image!.path)),
          ],
          ElevatedButton(
            onPressed: _takePhoto,
            child: Text('Capture'),
          ),
        ],
      ),
    );
  }
}

class QRScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
          }
        },
      ),
    );
  }
}
