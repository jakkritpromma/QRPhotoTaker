import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class CameraEvent {}

class InitializeCamera extends CameraEvent {}

class TakePhoto extends CameraEvent {}

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraInitialized extends CameraState {
  final CameraController controller;
  final AssetEntity latestPhoto;
  CameraInitialized(this.controller, this.latestPhoto);
}

class PhotoCaptured extends CameraState {
  final XFile photo;
  PhotoCaptured(this.photo);
}

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final String TAG = "CameraBloc MyLog ";
  final List<CameraDescription> cameras;
  CameraController? _controller;
  AssetEntity? _latestPhoto;

  CameraBloc(this.cameras) : super(CameraInitial()) {
    on<InitializeCamera>(_initializeCamera);
    on<TakePhoto>(_takePhoto);
  }

  Future<void> _initializeCamera(InitializeCamera event, Emitter<CameraState> emit) async {
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || await Permission.photos.request().isGranted) {
      await updatePhoto();
    } else if (ps == PermissionState.denied) {
      print(TAG + 'Permission denied. Please allow access in the app settings.');
    } else if (ps == PermissionState.limited) {
      print(TAG + 'Limited access to photos.');
    } else {
      print(TAG + 'Please allow access in the app settings.');
    }
    emit(CameraInitialized(_controller!, _latestPhoto!));
  }

  Future<void> updatePhoto() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    if (albums.isNotEmpty) {
      List<AssetEntity> photos = await albums[0].getAssetListRange(start: 0, end: 1);

      if (photos.isNotEmpty) {
        _latestPhoto = photos.first;
      }
    }
  }

  Future<void> _takePhoto(TakePhoto event, Emitter<CameraState> emit) async {
    try {
      final XFile file = await _controller!.takePicture();
      final List<int> fileBytes = await file.readAsBytes();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '/storage/emulated/0/DCIM/Camera/$fileName';

      // Save file to DCIM on Android
      if (Platform.isAndroid) {
        await saveFileToDCIM(fileName, fileBytes);
        print('$TAG Scanning file at path: $filePath');
        await _scanMedia(filePath);
      }

      // Save file to iOS Photos Library
      if (Platform.isIOS) {
        await saveFileToGallery(fileBytes, fileName);
      }

      //emit(PhotoCaptured(file));
      updatePhoto();
      emit(CameraInitialized(_controller!, _latestPhoto!));
    } catch (e) {
      print('$TAG Error capturing photo: $e');
    }
  }

  Future<void> saveFileToGallery(List<int> fileBytes, String fileName) async {
    try {
      // Request permissions to access the photo gallery
      final permission = await PhotoManager.requestPermissionExtend();
      if (permission.isAuth) {
        // Save the file to the gallery
        await PhotoManager.editor.saveImage(
          Uint8List.fromList(fileBytes),
          title: fileName, // 'title' is required, so we're passing fileName
          filename: fileName, // Add 'filename' as a required parameter
        );
        print('$TAG File saved to iOS Photos Library: $fileName');
      } else {
        print('$TAG Permission denied to access the photo gallery.');
      }
    } catch (e) {
      print('$TAG Error saving file to iOS gallery: $e');
    }
  }

  Future<void> saveFileToDCIM(String fileName, List<int> fileBytes) async {
    final directory = Directory('/storage/emulated/0/DCIM/Camera');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true); // Create the directory if it doesn't exist
      print('$TAG Created DCIM/Camera directory');
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    print('$TAG File saved at $filePath');
    print('$TAG File exists after saving: ${file.existsSync()}');
  }

  Future<void> _scanMedia(String path) async {
    const platform = MethodChannel('com.jakkagaku.qrphototaker/media_scan');
    try {
      print("$TAG Dart: Invoking media scan for path: $path");
      await platform.invokeMethod('scanFile', {'path': path});
      print("$TAG Dart: Media scanner invoked successfully");
    } catch (e) {
      print("$TAG Dart: Error invoking media scanner: $e");
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
