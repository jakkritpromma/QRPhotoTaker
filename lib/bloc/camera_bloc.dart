import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';

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
    if (_controller != null) {
      final photo = await _controller!.takePicture();
      emit(PhotoCaptured(photo));
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
