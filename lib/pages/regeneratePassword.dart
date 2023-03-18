import 'package:budgetly/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RegeneratePassword extends StatefulWidget {
  const RegeneratePassword(
      {Key? key, required this.title, required this.argsEmail})
      : super(key: key);
  final String title;
  final String argsEmail;

  @override
  RegeneratePasswordState createState() => RegeneratePasswordState();
}

class RegeneratePasswordState extends State<RegeneratePassword> {
  double? _deviceHeight, _deviceWidth;
  final _formKey = GlobalKey<FormState>();
  String? password;
  TextEditingController passwordTxt = TextEditingController();
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';

  bool passwordVisible = false;

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
              SizedBox(
                width: _deviceWidth! > 500
                    ? _deviceWidth! * 0.5
                    : _deviceWidth! * 0.8,
                child: Text(
                  "Regénérer mot de passe".toUpperCase(),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: _deviceWidth! > 500
                        ? _deviceWidth! * 0.04
                        : _deviceWidth! * 0.09,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: _deviceHeight! * 0.15),
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
                    labelText: 'Nouveau mot de passe'.toUpperCase(),
                    labelStyle: GoogleFonts.roboto(
                      color: Colors.grey,
                      fontSize: _deviceWidth! > 500
                          ? _deviceWidth! * 0.022
                          : _deviceWidth! * 0.04,
                      fontWeight: FontWeight.w700,
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
                    return null;
                  },
                  onFieldSubmitted: (value) =>
                      {updateUserPassword(password, widget.argsEmail)},
                ),
              ),
              SizedBox(height: _deviceHeight! * 0.05),
              ElevatedButton(
                onPressed: () {
                  updateUserPassword(password, widget.argsEmail);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  backgroundColor: "EC6463".toColor(),
                ),
                child: Text(
                  "Valider mon nouveau mot de passe".toUpperCase(),
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: _deviceWidth! > 500
                        ? _deviceWidth! * 0.022
                        : _deviceWidth! * 0.04,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateUserPassword(String? password, String email) async {
    var response = await http.post(Uri.parse(
        "$serverUrl/updateUserPassword?email=$email&password=$password"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context,
          const Text("Problème lors de la mise à jour de votre mot de passe"));
    } else {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Mot de passe modifié"));
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(
        "/login",
      );
    }
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }
}
