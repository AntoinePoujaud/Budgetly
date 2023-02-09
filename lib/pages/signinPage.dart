// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  double? _deviceHeight, _deviceWidth;
  final _formKey = GlobalKey<FormState>();
  String? mail, password;
  TextEditingController passwordTxt = TextEditingController();
  TextEditingController emailTxt = TextEditingController();
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';
  bool passwordVisible = false;

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 23, 26),
      body: Center(
        child: SizedBox(
          height: _deviceHeight! * 1,
          width: _deviceWidth! * 0.3,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Créer un compte",
                  style: TextStyle(color: Colors.white, fontSize: 60),
                ),
                SizedBox(height: _deviceHeight! * 0.15),
                TextFormField(
                  controller: emailTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: _deviceWidth! * 0.015,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _deviceWidth! * 0.015,
                  ),
                  onChanged: ((value) {
                    setState(() {
                      mail = value;
                    });
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: _deviceHeight! * 0.05),
                TextFormField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  controller: passwordTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: _deviceWidth! * 0.015,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _deviceWidth! * 0.015,
                  ),
                  onChanged: ((value) {
                    setState(() {
                      password = value;
                    });
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: _deviceHeight! * 0.05),
                ElevatedButton(
                  onPressed: () {
                    addUserIfNew(emailTxt.text, passwordTxt.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    backgroundColor: const Color.fromARGB(255, 29, 161, 242),
                  ),
                  child: Text(
                    "Créer un compte",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _deviceWidth! * 0.015,
                    ),
                  ),
                ),
                SizedBox(height: _deviceHeight! * 0.05),
                RichText(
                  text: TextSpan(
                      text: "Se connecter",
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamed("/login");
                        }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addUserIfNew(String mail, String password) async {
    if (emailTxt.text == "") {
      throw Exception("mail can't be empty");
    }
    addUser(mail, password);
  }

  Future<void> addUser(String mail, String password) async {
    var response = await http.post(Uri.parse(
        "$serverUrl/addUser?email=$mail&password=$password"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Error while creating account"));
    } else {
      String userId = json.decode(response.body)["id"].toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed("/");
    }
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }
}
