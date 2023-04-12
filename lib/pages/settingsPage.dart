// ignore_for_file: file_names

import 'dart:convert';

import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double? _deviceHeight, _deviceWidth;
  double startingAmountAccount = 0;
  String currentPage = 'Paramètres';
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
      backgroundColor: "#CCE4DD".toColor(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuLayout(
              title: widget.title,
              deviceWidth: _deviceWidth,
              deviceHeight: _deviceHeight),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: _deviceWidth! * 0.82,
                height: _deviceHeight! * 0.9,
                child: Column(
                  children: [
                    const Text("Définir le montant initial du compte : "),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      initialValue: startingAmountAccount.toString(),
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: _deviceWidth! * 0.018,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: ((value) {
                        setState(() {
                          startingAmountAccount = double.parse(value).toDouble();
                        });
                      }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: _deviceHeight! * 0.05),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(25.0),
                            backgroundColor: "#EC6463".toColor(),
                          ),
                          child: Text(
                            'label_update_starting_amount'.i18n().toUpperCase(),
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: _deviceWidth! * 0.018,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await updateStartingAmountForUser(
                                  startingAmountAccount);
                              // ignore: use_build_context_synchronously
                              showToast(
                                  context,
                                  const Text(
                                      "Initial amount updated successfully"));
                            } catch (e) {
                              showToast(
                                  context,
                                  const Text(
                                      "Error while updating initial amount"));
                            }
                          }),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> updateStartingAmountForUser(
    double amount,
  ) async {
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.post(
        Uri.parse("$serverUrl/updateInitialAmount/$userId?amount=$amount"));
  }

  Future<void> getStartingAmountForUser() async {
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response =
        await http.get(Uri.parse("$serverUrl/getInitialAmount/$userId"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Can't fetch your initial amount"));
    } else {
      setState(() {
        startingAmountAccount = json.decode(response.body)["amount"];
      });
    }
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }
}
