import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laravel/api.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class LoginQrCodeScreen extends StatefulWidget {
  const LoginQrCodeScreen({Key? key}) : super(key: key);

  @override
  State<LoginQrCodeScreen> createState() => _LoginQrCodeScreenState();
}

class _LoginQrCodeScreenState extends State<LoginQrCodeScreen> {

  bool _status = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result!.format != null && result!.code != null && _status == false) {
        setState(() {
          _status = true;
        });
        // print('Barcode Type: ${describeEnum(result!.format)}, Data: ${result!.code}');
        Api.validateToken(
          result!.code,
          (String errorMesage) {
            setState(() {
              _status = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMesage)));
          },
          () {
            Timer(Duration(seconds: 1), () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
          },
          context,
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
