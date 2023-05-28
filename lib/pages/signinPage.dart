// ignore_for_file: file_names

import 'dart:convert';

import 'package:budgetly/utils/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

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
      backgroundColor: "063545".toColor(),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "label_create_account".toUpperCase(),
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: _deviceWidth! > 500
                      ? _deviceWidth! * 0.04
                      : _deviceWidth! * 0.09,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: _deviceHeight! * 0.15),
              SizedBox(
                width: _deviceWidth! > 500
                    ? _deviceWidth! * 0.5
                    : _deviceWidth! * 0.8,
                child: TextFormField(
                  controller: emailTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'label_email'.i18n().toUpperCase(),
                    labelStyle: GoogleFonts.roboto(
                      color: Colors.grey,
                      fontSize: _deviceWidth! > 500
                          ? _deviceWidth! * 0.022
                          : _deviceWidth! * 0.04,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: _deviceWidth! > 500
                        ? _deviceWidth! * 0.022
                        : _deviceWidth! * 0.04,
                    fontWeight: FontWeight.w700,
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
                  onFieldSubmitted: (value) =>
                      {addUserIfNew(emailTxt.text, passwordTxt.text)},
                ),
              ),
              SizedBox(height: _deviceHeight! * 0.05),
              SizedBox(
                width: _deviceWidth! > 500
                    ? _deviceWidth! * 0.5
                    : _deviceWidth! * 0.8,
                child: TextFormField(
                  obscureText: !passwordVisible,
                  obscuringCharacter: "*",
                  controller: passwordTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'label_password'.i18n().toUpperCase(),
                    labelStyle: GoogleFonts.roboto(
                      color: Colors.grey,
                      fontSize: _deviceWidth! > 500
                          ? _deviceWidth! * 0.022
                          : _deviceWidth! * 0.04,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  onFieldSubmitted: (value) =>
                      {addUserIfNew(emailTxt.text, passwordTxt.text)},
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: _deviceWidth! > 500
                        ? _deviceWidth! * 0.022
                        : _deviceWidth! * 0.04,
                    fontWeight: FontWeight.w700,
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
              ),
              SizedBox(height: _deviceHeight! * 0.05),
              ElevatedButton(
                onPressed: () {
                  addUserIfNew(emailTxt.text, passwordTxt.text);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20.0),
                  backgroundColor: "EC6463".toColor(),
                ),
                child: Text(
                  "label_sign_in".i18n().toUpperCase(),
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: _deviceWidth! > 500
                        ? _deviceWidth! * 0.022
                        : _deviceWidth! * 0.04,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: _deviceHeight! * 0.05),
              RichText(
                text: TextSpan(
                    text: "label_connect_title".i18n().toUpperCase(),
                    style: GoogleFonts.roboto(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed("/login");
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addUserIfNew(String mail, String password) async {
    if (emailTxt.text == "") {
      showToast(context, const Text("mail can't be empty"));
    } else {
      addUser(mail, password);
    }
  }

  Future<void> addUser(String mail, String password) async {
    var response = await http
        .post(Uri.parse("$serverUrl/addUser?email=$mail&password=$password"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Error while creating account"));
    } else {
      String userId = json.decode(response.body)["id"].toString();
      String token = json.decode(response.body)["token"].toString();
      setCookie("token", token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed("/settings");
    }
  }

  void setCookie(String name, String value, {int? maxAge}) {
    String cookie = '$name=$value';

    if (maxAge != null) {
      final expires = DateTime.now().add(Duration(seconds: maxAge));
      cookie += '; expires=${expires.toUtc().toString()}';
    }

    html.window.document.cookie = cookie;
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }
}
