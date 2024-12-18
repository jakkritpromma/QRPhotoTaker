import 'package:flutter/material.dart';
import 'package:qrphototaker/bloc/qr_scanner_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qrScannerBloc = BlocProvider.of<QRScannerBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                qrScannerBloc.add(QRCodeDetected(barcode));
              }
            },
          ),
          BlocBuilder<QRScannerBloc, QRScannerState>(
            builder: (context, state) {
              if (state is QRCodeScanned) {
                return Center(
                  child: AlertDialog(
                    title: Text('QR Code Found'),
                    content: Text(state.qrCode),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}