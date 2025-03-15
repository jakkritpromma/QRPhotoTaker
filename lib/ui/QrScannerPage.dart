import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrphototaker/bloc/QrScannerBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkCameraPermission(context);
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
                  child: Builder(
                    builder: (dialogContext) => AlertDialog(
                      title: Text('QR Code Found'),
                      content: GestureDetector(
                        onTap: () async {
                          final url = state.qrCode;
                          if (url != null) {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
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
                          onPressed: () {
                            if (state.qrCode != null) {
                              Share.share(state.qrCode.toString());
                            }
                          },
                          child: Text('Share'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.read<QRScannerBloc>().add(ResetQRCode()),
                          child: Text('OK'),
                        ),
                      ],
                    ),
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

  Future<void> checkCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      // Request permission only if not asked before
      final newStatus = await Permission.camera.request();
      if (newStatus.isDenied) {
        // If user denies again, show custom dialog
        showPermissionDeniedDialog(context);
      }
    } else if (status.isPermanentlyDenied) {
      // User permanently denied permission, show custom dialog
      showPermissionDeniedDialog(context);
    }
  }

  void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('The camera permission is denied. Please enable it in Settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to the previous page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
