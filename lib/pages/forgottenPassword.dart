// ignore_for_file: file_names

import 'package:budgetly/utils/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
                "Mot de passe oublié".toUpperCase(),
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
                    labelText: 'Email'.toUpperCase(),
                    labelStyle: GoogleFonts.roboto(
                      color: Colors.grey,
                      fontSize: _deviceWidth! > 500
                          ? _deviceWidth! * 0.022
                          : _deviceWidth! * 0.04,
                    ),
                  ),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: _deviceWidth! > 500
                        ? _deviceWidth! * 0.022
                        : _deviceWidth! * 0.04,
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
                      {sendVerificationCodeToUser(emailTxt.text)},
                ),
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
                        backgroundColor: "EC6463".toColor(),
                      ),
                      child: Text(
                        "Envoyer mon code de vérification".toUpperCase(),
                        style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: _deviceWidth! > 500
                                ? _deviceWidth! * 0.022
                                : _deviceWidth! * 0.04,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  : Container(
                      child: verifCodeWidget(),
                    ),
              SizedBox(height: _deviceHeight! * 0.05),
              RichText(
                text: TextSpan(
                    text: "Retour".toUpperCase(),
                    style: GoogleFonts.roboto(
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
    );
  }

  void sendVerificationCodeToUser(String email) async {
    var response =
        await http.get(Uri.parse("$serverUrl/sendMailPassword?email=$email"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(
          context, const Text("Nous ne connaissons pas cette adresse mail"));
      setState(() {
        mailSentSuccessfully = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      showToast(
          context,
          const Text(
              "Si votre email est dans notre base de données, un mail vous a été envoyé"));
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
        showToast(
            context, const Text("Votre code de vérification est incorrect"));
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
        SizedBox(
          width:
              _deviceWidth! > 500 ? _deviceWidth! * 0.5 : _deviceWidth! * 0.8,
          child: Text(
            "Vérifiez votre boîte mail, un code de vérification vous a été envoyé"
                .toUpperCase(),
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: _deviceWidth! > 500
                  ? _deviceWidth! * 0.022
                  : _deviceWidth! * 0.03,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width:
              _deviceWidth! > 500 ? _deviceWidth! * 0.5 : _deviceWidth! * 0.8,
          child: TextFormField(
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
            ],
            decoration: InputDecoration(
              hintText: "012345",
              hintStyle: GoogleFonts.roboto(
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
            ),
            onChanged: (value) {
              if (value.length == 6) {
                verifCode = value.toString();
                checkVerifCode(verifCode!, emailTxt.text);
              }
            },
          ),
        ),
        SizedBox(height: _deviceHeight! * 0.05),
      ],
    );
  }
}
