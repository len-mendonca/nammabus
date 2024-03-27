// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;

// class GenerateQRCode extends StatefulWidget {
//   const GenerateQRCode({super.key});

//   @override
//   GenerateQRCodeState createState() => GenerateQRCodeState();
// }

// class GenerateQRCodeState extends State<GenerateQRCode> {
//   String qrCodeData = "";
//   String btn = "Buy Ticket";
//   bool isButtonEnabled = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Code Generator'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(100, 100, 100, 20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             ElevatedButton(
//                 onPressed: isButtonEnabled ? generateQRCode : null,
//                 child: isButtonEnabled
//                     ? const Text('Buy Ticket',
//                         style: TextStyle(color: Color(0xffFF8700)))
//                     : const Text(
//                         "Your Ticket 👇",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w900,
//                         ),
//                       )),
//             const SizedBox(height: 20),
//             isButtonEnabled
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         "    Ticket Will be \n downloaded here",
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             textBaseline: TextBaseline.alphabetic),
//                       ),
//                     ),
//                   )
//                 : QrImageView(
//                     data: qrCodeData,
//                     version: QrVersions.auto,
//                     size: 200,
//                   )
//           ],
//         ),
//       ),
//     );
//   }

//   void generateQRCode() {
//     setState(() {
//       qrCodeData = const Uuid().v4();

//       isButtonEnabled = false;
//       btn = "Your Ticket 👇";
//       setState(() {
//         btn;
//       });
//     });

//     sendTicketToBackend(qrCodeData);
//     print(qrCodeData);
//   }
// }

// Future<void> sendTicketToBackend(String ticketid) async {
//   final url =
//       'http://192.168.56.1:3000/createticket'; // Replace with your backend URL

//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       body: {'ticketid': ticketid},
//     );

//     if (response.statusCode == 200) {
//       print('Ticket ID sent successfully');
//     } else {
//       print('Failed to send Ticket ID. Status code: ${response.statusCode}');
//     }
//   } catch (error) {
//     print('Error sending Ticket ID: $error');
//   }
// }

// import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const String url = "https://ekfouxfsolardpgzdkzz.supabase.co";
const String anonKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrZm91eGZzb2xhcmRwZ3pka3p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk0NTkzMTcsImV4cCI6MjAyNTAzNTMxN30.bcm-C8nw23uiPP4fsLw63eZBZqIih8d2hs023WMfx8s";

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({super.key});

  @override
  GenerateQRCodeState createState() => GenerateQRCodeState();
}

class GenerateQRCodeState extends State<GenerateQRCode> {
  String qrCodeData = "";
  // @override
  // Future<void> initState()  {
  //   super.initState();
  //    initializeSupabase();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(100, 100, 100, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateQRCode,
              child: const Text('Buy Ticket'),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrCodeData,
              version: QrVersions.auto,
              size: 200,
            )
          ],
        ),
      ),
    );
  }

  void generateQRCode() {
    setState(() {
      qrCodeData = const Uuid().v4();
    });

    sendTicketToBackend(qrCodeData);
    print(qrCodeData);
  }
}

Future<void> sendTicketToBackend(String ticketid) async {
  // const url = 'http://192.168.5.160:3000/createticket'; // Replace with your backend URL

  // try {
  //   final response = await http.post(
  //     Uri.parse(url),
  //     body: {'ticketid': ticketid},
  //   );

  //   if (response.statusCode == 200) {
  //     print('Ticket ID sent successfully');
  //   } else {
  //     print('Failed to send Ticket ID. Status code: ${response.statusCode}');
  //   }
  // } catch (error) {
  //   print('Error sending Ticket ID: $error');
  // }
  print("Ticket id is " + ticketid);
  final response = await supabase
      .from('Tickets')
      .insert({'ticket_id': ticketid, 'validity': 1, 'userid': '111111'});
  print(response);
}

final supabase = SupabaseClient(url, anonKey);
