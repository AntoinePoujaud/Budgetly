// ignore_for_file: file_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mysql.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  double? _deviceHeight, _deviceWidth;
  var db = Mysql();
  final _formKey = GlobalKey<FormState>();
  String? mail, password;

  TextEditingController passwordTxt = TextEditingController();
  TextEditingController emailTxt = TextEditingController();

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
                  "Se connecter",
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
                  controller: passwordTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
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
                    login(context, emailTxt.text, passwordTxt.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    backgroundColor: const Color.fromARGB(255, 29, 161, 242),
                  ),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _deviceWidth! * 0.015,
                    ),
                  ),
                ),
                SizedBox(height: _deviceHeight! * 0.05),
                RichText(
                  text: TextSpan(
                      text: "Créer un compte",
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, "/signIn");
                        }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(BuildContext context, String mail, String password) async {
    if (await checkIfMailExists(mail)) {
      if (await checkIfPasswordIsCorrect(mail, password)) {
        String userId = await getUserId();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, "/");
      } else {
        throw Exception("Password incorrect. Please try again");
      }
    } else {
      throw Exception("This mail doesn't exists");
    }
  }

  Future<String> getUserId() async {
    String? userId;
    String query = "SELECT id FROM user where email = '$mail'";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      userId = row.assoc().values.first.toString();
    });
    await connection.close();
    return userId!;
  }

  Future<bool> checkIfMailExists(String mail) async {
    bool isMailAlreadyExists = false;
    String query = "SELECT email FROM user where email = '$mail'";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      if (row.assoc().values.first.toString() == mail) {
        isMailAlreadyExists = true;
      } else {
        isMailAlreadyExists = false;
      }
    });
    await connection.close();
    return isMailAlreadyExists;
  }

  Future<bool> checkIfPasswordIsCorrect(String mail, String password) async {
    bool isPasswordCorrect = false;
    String query = "SELECT password FROM user WHERE email = '$mail'";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      if (row.assoc().values.first.toString() == password) {
        isPasswordCorrect = true;
      } else {
        isPasswordCorrect = false;
      }
    });
    await connection.close();
    return isPasswordCorrect;
  }
}
