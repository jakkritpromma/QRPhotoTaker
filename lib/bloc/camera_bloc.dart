import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

abstract class CameraEvent {}

class InitializeCamera extends CameraEvent {}

class TakePhoto extends CameraEvent {}

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraInitialized extends CameraState {
  final CameraController controller;

  CameraInitialized(this.controller);
}

class PhotoCaptured extends CameraState {
  final XFile photo;

  PhotoCaptured(this.photo);
}

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final String TAG = "CameraBloc MyLog ";
  final List<CameraDescription> cameras;
  CameraController? _controller;

  CameraBloc(this.cameras) : super(CameraInitial()) {
    on<InitializeCamera>(_initializeCamera);
    on<TakePhoto>(_takePhoto);
  }

  Future<void> _initializeCamera(InitializeCamera event, Emitter<CameraState> emit) async {
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    emit(CameraInitialized(_controller!));
  }

  Future<void> _takePhoto(TakePhoto event, Emitter<CameraState> emit) async {
    try {
        final XFile file = await _controller!.takePicture();
        final List<int> fileBytes = await file.readAsBytes();
        final String fileName = '${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg'; // Generate a unique file name for the photo
        await saveFileToDCIM(fileName, fileBytes);
        print(TAG + 'Photo saved to DCIM directory: $fileName');
        _scanMedia('/storage/emulated/0/DCIM/$fileName');
        emit(PhotoCaptured(file));
    } catch (e) {
      print(TAG + 'Error capturing photo: $e');
    }
  }

  Future<void> saveFileToDCIM(String fileName, List<int> fileBytes) async {
    final directory = Directory('/storage/emulated/0/DCIM');
    if (!directory.existsSync()) {
      throw Exception(TAG + "DCIM folder does not exist.");
    }
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);
    print(TAG + "File saved at $filePath");
  }

  //Notify the media scanner to update the gallery
  Future<void> _scanMedia(String path) async {
    try {
      final result = await Process.run(
        'content',
        ['broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE', 'file://$path'],
      );
      print(TAG + 'Media scanner result: $result');
    } catch (e) {
      print(TAG + 'Error scanning media: $e');
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
