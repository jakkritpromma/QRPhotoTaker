import 'package:bloc/bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

abstract class QRScannerEvent {}
class QRCodeDetected extends QRScannerEvent {
  final Barcode barcode;
  QRCodeDetected(this.barcode);
}

abstract class QRScannerState {}
class QRScannerInitial extends QRScannerState {}
class QRCodeScanned extends QRScannerState {
  final String qrCode;
  QRCodeScanned(this.qrCode);
}

class ResetQRCode extends QRScannerEvent {}

class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> {
  QRScannerBloc() : super(QRScannerInitial()) {
    on<QRCodeDetected>((event, emit) {
      emit(QRCodeScanned(event.barcode.rawValue ?? 'Unknown'));
    });

    on<ResetQRCode>((event, emit) {
      emit(QRScannerInitial());
    });
  }
}
