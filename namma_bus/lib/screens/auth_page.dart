import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:namma_bus/screens/big_screen.dart';
import 'package:namma_bus/screens/signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.56.1:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Login successful
      final responseData = jsonDecode(response.body);
      print(responseData['message']);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      // Login failed
      final responseData = jsonDecode(response.body);
      print(responseData['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: <Widget>[
              const SizedBox(height: 20),
              Image.asset(
                'assets/namma_bus_logo.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 20),
              const Text(
                'User\nAuthentication',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xffFF8700),
                    fontSize: 45,
                    height: 0.8,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                width: 0.8 * MediaQuery.of(context).size.width,
                height: 50.0,
                alignment: Alignment.topLeft,
                decoration: const BoxDecoration(
                  color: Color(0xffFFF7E8),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 20),
                    hintText: 'Email',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color(0xffFF8700), fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                width: 0.8 * MediaQuery.of(context).size.width,
                height: 50.0,
                alignment: Alignment.topLeft,
                decoration: const BoxDecoration(
                  color: Color(0xffFFF7E8),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 20),
                    hintText: 'Password',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color(0xffFF8700), fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xffFF8700),
                  minimumSize:
                      Size(0.8 * MediaQuery.of(context).size.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _login,
                child: const Text('Log In', style: TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: Color(0xffFF8700)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xffFF8700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
