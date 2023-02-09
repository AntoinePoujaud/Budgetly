// ignore_for_file: file_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


class ForgottenPassword extends StatefulWidget {
  const ForgottenPassword({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  ForgottenPasswordPageState createState() => ForgottenPasswordPageState();
}

class ForgottenPasswordPageState extends State<ForgottenPassword> {
  double? _deviceHeight, _deviceWidth;
  final _formKey = GlobalKey<FormState>();
  String? mail, password;
  TextEditingController passwordTxt = TextEditingController();
  TextEditingController emailTxt = TextEditingController();
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';
  bool mailSentSuccessfully = false;
  String? verifCode;
  bool isVerifCodeCorrect = false;

  @override
  void initState() {
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
                  "Mot de passe oublié",
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
// if mail sent and response = 200
                !mailSentSuccessfully
                    ? ElevatedButton(
                        onPressed: () {
                          sendVerificationCodeToUser(emailTxt.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 29, 161, 242),
                        ),
                        child: Text(
                          "Envoyer mon code de vérification",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _deviceWidth! * 0.015,
                          ),
                        ),
                      )
                    : Container(
                        child: verifCodeWidget(),
                      ),
                SizedBox(height: _deviceHeight! * 0.05),
                RichText(
                  text: TextSpan(
                      text: "Retour",
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

  void sendVerificationCodeToUser(String email) async {
    var response =
        await http.get(Uri.parse("$serverUrl/sendMailPassword?email=$email"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      setState(() {
        mailSentSuccessfully = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Mail sent!"));
      setState(() {
        mailSentSuccessfully = true;
      });
    }
  }

  Future<void> checkVerifCode(String verifCode, email) async {
    var response = await http.get(Uri.parse(
        "$serverUrl/checkVerifCode?email=$email&&verifCode=$verifCode"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      setState(() {
        isVerifCodeCorrect = false;
        showToast(context,
                          const Text("Votre code de vérification est incorrect"));
      });
    } else {
      setState(() {
        isVerifCodeCorrect = true;
        Navigator.of(context).pushNamed(
          "/forgotPassword/newPassword",
          arguments: {"email": email},
        );
      });
    }
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }

  Widget verifCodeWidget() {
    return Column(
      children: [
        Text(
          "Vérifiez votre boîte mail, un code de vérification vous a été envoyé",
          style:
              TextStyle(color: Colors.white, fontSize: _deviceWidth! * 0.015),
        ),
        TextFormField(
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
          ],
          decoration: InputDecoration(
            hintText: "012345",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: _deviceWidth! * 0.015,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: _deviceWidth! * 0.015,
          ),
          onChanged: (value) {
            if (value.length == 6) {
              verifCode = value.toString();
              checkVerifCode(verifCode!, emailTxt.text);
            }
          },
        ),
        SizedBox(height: _deviceHeight! * 0.05),
      ],
    );
  }
}
