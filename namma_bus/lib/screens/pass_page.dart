import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var name;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Future<void> _sendPassEntry() async {
    final url = Uri.parse('http://192.168.56.1:3000/api/storePassEntry');

    try {
      final response = await http.post(
        url,
        body: {
          'name': nameController.text,
          'age': ageController.text,
          'address': addressController.text,
          'passid': const Uuid().v4(),
        },
      );
      if (response.statusCode == 200) {
        print('Pass entry sent successfully');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EbusPassPage(
                  // name: nameController.text,
                  // age: ageController.text,
                  // address: addressController.text,
                  // passid: const Uuid().v4(),
                  ),
            ),
          );
        }
        // Navigate to the E-bus pass page or show a success message as needed
      } else {
        print('Failed to send pass entry. Status code: ${response.statusCode}');
        // Handle error, show an error message, etc.
      }
    } catch (e) {
      print('Error sending pass entry: $e');
      // Handle error, show an error message, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bus Pass Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendPassEntry();
                  }
                },
                child: const Text('Generate E-bus Pass'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EbusPassPage extends StatelessWidget {
  final String? name;
  final String? age;
  final String? address;
  final String? passid;
  const EbusPassPage(
      {super.key, this.name, this.age, this.address, this.passid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bus Pass'),
      ),
      body: const Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Name: Ananth'),
                ),
                ListTile(
                  leading: Icon(Icons.cake),
                  title: Text('Age: 19'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Address: ABC Apartments'),
                ),
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Validity: 2024-04-23'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
