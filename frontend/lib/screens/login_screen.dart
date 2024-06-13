import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/error_snackbar.dart';
import 'package:frontend/utils/encrypted_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hidden = true;
  bool _loading = false;
  final _passwordEditingController = TextEditingController();
  final _usernameEditingController = TextEditingController();

  Future<void> handleLogin() async {
    String username = _usernameEditingController.text;
    String password = _passwordEditingController.text;
    _usernameEditingController.clear();
    _passwordEditingController.clear();

    var response = await http.post(APIConstants.loginUri,
        body: {'username': username, 'password': password});
	var responseBody = jsonDecode(response.body) as Map ;
    if (response.statusCode == 200) {
	    await EncryptedStorage().set(key: "jwt", value: responseBody["access_token"]);
	    Navigator.of(context).pushReplacementNamed("/home");
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(getErrorSnackBar(responseBody['message']));
    }
  }

  @override
  void dispose() {
    _usernameEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "DiscourseDen",
                style: TextStyle(fontSize: 54),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _usernameEditingController,
                decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    hintText: "Username"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordEditingController,
                obscureText: _hidden,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  icon: const Icon(Icons.key),
                  hintText: "Password",
                  suffixIcon: IconButton(
                    icon:
                        Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _hidden = !_hidden;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: _loading ? (){} : handleLogin,
                color: Colors.deepPurple,
                height: 60,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              /*
               *SizedBox(
               *  height: 10,
               *),
               *MaterialButton(
               *  onPressed: () {},
               *  height: 60,
	       *  textColor: Colors.deepPurple,
               *  shape: RoundedRectangleBorder(
               *      borderRadius: BorderRadius.circular(12)),
               *  child: const Text(
               *    "Register",
               *    style: TextStyle(fontSize: 20),
               *  ),
               *)
	       */
            ],
          ),
        ),
      ),
    );
  }
}
