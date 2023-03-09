import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
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
                  "Regénérer mot de passe",
                  style: TextStyle(color: Colors.white, fontSize: 60),
                ),
                SizedBox(height: _deviceHeight! * 0.15),
                TextFormField(
                  controller: passwordTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
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
                    return null;
                  },
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
                    backgroundColor: const Color.fromARGB(255, 29, 161, 242),
                  ),
                  child: Text(
                    "Valider mon nouveau mot de passe",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _deviceWidth! * 0.015,
                    ),
                  ),
                ),
              ],
            ),
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
