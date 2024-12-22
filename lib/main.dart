import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrphototaker/bloc/qr_scanner_bloc.dart';
import 'package:qrphototaker/bloc/camera_bloc.dart';
import 'package:qrphototaker/ui/home_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestStoragePermissions();
  await requestPhotosPermission();
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

Future<void> requestStoragePermissions() async {
  final String TAG = "requestStoragePermissions MyLog ";
  // For Android 10 and below
  if (await Permission.storage.request().isGranted) {
    print(TAG + "Storage permission granted.");
  }

  // For Android 11+ (API 30+)
  if (!await Permission.manageExternalStorage.isGranted) {
    // Check if the app needs to open settings
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final status = await Permission.manageExternalStorage.request();
      print(TAG + "Permission status: $status");
    }
  }
}

Future<void> requestPhotosPermission() async {
  final String TAG = "requestPhotosPermission MyLog ";
  final status = await Permission.photos.request();

  if (status.isGranted) {
    print(TAG + "Photos and Videos permission granted.");
  } else if (status.isDenied) {
    print(TAG + "Permission denied. Please try again.");
  } else if (status.isPermanentlyDenied) {
    print(TAG + "Permission permanently denied. Open settings.");
    await openAppSettings(); // Redirect to settings if permission is permanently denied
  }
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

