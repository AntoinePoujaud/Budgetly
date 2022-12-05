// ignore_for_file: file_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'mysql.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
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
                          Navigator.pushNamed(context, "/login");
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
    bool isMailAlreadyExists = false;
    if (emailTxt.text != "") {
      isMailAlreadyExists = await checkIfMailExists(mail);
    } else {
      throw Exception("mail can't be empty");
    }
    if (!isMailAlreadyExists) {
      addUser(mail, password);
    } else {
      throw Exception("mail already exists");
    }
  }

  Future<void> addUser(String mail, String password) async {
    String query =
        "INSERT INTO user (email, password, current_amount, current_real_amount) VALUES ('$mail', '$password', 0, 0)";
    var connection = await db.getConnection();
    await connection.execute(query);
    await connection.close();
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
}
