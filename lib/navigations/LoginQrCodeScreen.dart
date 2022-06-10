import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laravel/api.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_laravel/mixins/utils.dart';

class LoginQrCodeScreen extends StatefulWidget {
  const LoginQrCodeScreen({Key? key}) : super(key: key);

  @override
  State<LoginQrCodeScreen> createState() => _LoginQrCodeScreenState();
}

class _LoginQrCodeScreenState extends State<LoginQrCodeScreen> with FragmentUtils {

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
            flex: 1,
            child: _buildQrView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    if (controller != null)
        controller.resumeCamera();
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result!.format != null && result!.code != null && _status == false) {
        // print('Barcode Type: ${describeEnum(result!.format)}, Data: ${result!.code}');
        showloadingDialog(true, context);
        setState(() {
          _status = true;
        });
        Api.validateToken(
          result!.code,
          (String errorMesage) {
            showloadingDialog(false, context);
            setState(() {
              _status = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMesage)));
          },
          () {
            showloadingDialog(false, context);
            Timer(Duration(seconds: 1), () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
          },
          context,
        );
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
