import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namma_bus/DataHandler/mysql.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _formKey = GlobalKey<FormState>();
  var db = new Mysql();
  var busName = '';

  void _getCustomer() {
    print("Getting customer...");
    db.getConnection().then((value) async {
      print("Connection obtained: $value");

      print("Executing SQL:");

      var res =
          await value.query('select empname from employers where id=?', [1]);
      await Future.delayed(Duration(seconds: 2));

      for (var row in res) {
        print("Received result: $row");
        setState(() {
          busName = row[0];
          print("Updated busName: $busName");
        });
      }
    }).catchError((error) {
      print("Error obtaining connection: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.black12,
          body: ListView(
            children: [
              Text(
                "hi:",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "$busName",
                style: TextStyle(color: Colors.white),
              ),
              FloatingActionButton(
                onPressed: _getCustomer,
                child: Icon(Icons.add),
              ),
              Placeholder(
                fallbackHeight: 180,
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        style: const TextStyle(fontSize: 19),
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: EdgeInsets.all(20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                    width: 0, style: BorderStyle.none)),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Name",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            )),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Name cant be empty";
                          }
                          if (text.length < 2) {
                            return "Please Enter Valid Name";
                          }
                          if (text.length > 49) {
                            return "Name Cant be More than 50 characters long";
                          }
                          return null;
                        },
                        controller: nameTextEditingController,
                        onChanged: (text) {
                          setState(() {
                            nameTextEditingController.text = text;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
