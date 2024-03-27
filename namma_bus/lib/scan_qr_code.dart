import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({Key? key}) : super(key: key);

  @override
  _ScanQRCodeState createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  String qrResult = 'Scanned Data will appear here';
  bool isQrready = false;
  String qrr = 'Scanned Data will appear here';

  Future<void> scanQrcode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      isQrready = true;

      if (!mounted) return;

      setState(() {
        qrResult = qrCode;
      });
    } on PlatformException {
      qrResult = "Fail to read qr code";
    }
  }

  Future<void> sendQRCode() async {
    if (isQrready) {
      final response = await http.post(
        Uri.parse(
            'http://192.168.5.160:3000/validate'), // Replace with your Node.js server URL
        body: {'qrCodeData': qrResult},
      );

      if (response.statusCode == 200) {
        print('QR code validation result: ${response.body}');

        setState(() {
          qrr = response.body.toString();
        });
        // Handle the response from the server
      } else {
        print('Failed to send QR code: ${response.statusCode}');
        // Handle the error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              qrr,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: scanQrcode, child: const Text('Scan Code')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: sendQRCode, child: const Text('Send QR Code')),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ScanQRCode(),
  ));
}
