import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

// Camera Events
abstract class CameraEvent {}

class InitializeCamera extends CameraEvent {}

class TakePhoto extends CameraEvent {}

class TogglePreview extends CameraEvent {} // New event to start/stop previewing

// Camera States
abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraInitialized extends CameraState {
  final CameraController controller;
  final AssetEntity? latestPhoto;
  final bool isPreviewing; // Added preview tracking flag

  CameraInitialized(this.controller, this.latestPhoto, {this.isPreviewing = true});
}

class PhotoCaptured extends CameraState {
  final XFile photo;

  PhotoCaptured(this.photo);
}

// CameraBloc Implementation
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final String TAG = "CameraBloc MyLog ";
  final List<CameraDescription> cameras;
  CameraController? _controller;
  AssetEntity? _latestPhoto;
  bool _isPreviewing = false;

  CameraBloc(this.cameras) : super(CameraInitial()) {
    on<InitializeCamera>(_initializeCamera);
    on<TakePhoto>(_takePhoto);
    on<TogglePreview>(_togglePreview);
  }

  Future<void> _initializeCamera(InitializeCamera event, Emitter<CameraState> emit) async {
    if (cameras.isEmpty) {
      emit(CameraInitial());
      return;
    }

    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    _isPreviewing = true;

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || await Permission.photos.request().isGranted) {
      await _updateLatestPhoto();
    } else {
      print(TAG + 'Permission denied. Please allow access in the app settings.');
    }

    emit(CameraInitialized(_controller!, _latestPhoto, isPreviewing: _isPreviewing));
  }

  Future<void> _updateLatestPhoto() async {
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
      if (_controller == null || !_controller!.value.isInitialized) return;

      final XFile file = await _controller!.takePicture();
      final List<int> fileBytes = await file.readAsBytes();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '/storage/emulated/0/DCIM/Camera/$fileName';

      if (Platform.isAndroid) {
        await _saveFileToDCIM(fileName, fileBytes);
        await _scanMedia(filePath);
      } else if (Platform.isIOS) {
        await _saveFileToGallery(fileBytes, fileName);
      }

      await _updateLatestPhoto();
      emit(CameraInitialized(_controller!, _latestPhoto, isPreviewing: _isPreviewing));
    } catch (e) {
      print('$TAG Error capturing photo: $e');
    }
  }

  Future<void> _saveFileToGallery(List<int> fileBytes, String fileName) async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (permission.isAuth) {
        await PhotoManager.editor.saveImage(
          Uint8List.fromList(fileBytes),
          title: fileName,
          filename: fileName,
        );
        print('$TAG File saved to iOS Photos Library: $fileName');
      } else {
        print('$TAG Permission denied to access the photo gallery.');
      }
    } catch (e) {
      print('$TAG Error saving file to iOS gallery: $e');
    }
  }

  Future<void> _saveFileToDCIM(String fileName, List<int> fileBytes) async {
    final directory = Directory('/storage/emulated/0/DCIM/Camera');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('$TAG Created DCIM/Camera directory');
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    print('$TAG File saved at $filePath');
  }

  Future<void> _scanMedia(String path) async {
    const platform = MethodChannel('com.jakkagaku.qrphototaker/media_scan');
    try {
      await platform.invokeMethod('scanFile', {'path': path});
      print("$TAG Dart: Media scanner invoked successfully");
    } catch (e) {
      print("$TAG Dart: Error invoking media scanner: $e");
    }
  }

  Future<void> _togglePreview(TogglePreview event, Emitter<CameraState> emit) async {
    if (state is CameraInitialized) {
      _isPreviewing = !_isPreviewing;
      emit(CameraInitialized(_controller!, _latestPhoto, isPreviewing: _isPreviewing));
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
