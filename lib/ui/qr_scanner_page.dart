import 'package:flutter/material.dart';
import 'package:qrphototaker/bloc/qr_scanner_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    //content: Text(state.qrCode),
                    content: GestureDetector(
                      onTap: () async {
                        final url = state.qrCode;
                        if (url != null) {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            // Optional: Show error if the URL is invalid
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open the link')),
                            );
                          }
                        }
                      },
                      child: Text(
                        state.qrCode.toString(),
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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