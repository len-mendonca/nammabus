import 'package:flutter/material.dart';

class BusListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> busList;

  const BusListScreen({super.key, required this.busList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus List'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bus List',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: busList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> busInfo = busList[index];
                  String busName = busInfo['bus_name'];
                  String destination = busInfo['destination'];

                  return ListTile(
                    leading:
                        const Icon(Icons.directions_bus, color: Colors.blue),
                    title: Text(busName),
                    subtitle: Text(destination),
                    onTap: () {
                      // Handle bus item tap if needed
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
