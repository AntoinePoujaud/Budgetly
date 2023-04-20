// ignore_for_file: file_names

import 'dart:convert';

import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:budgetly/utils/utils.dart';
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
  String startingAmountAccount = "0";
  String currentPage = 'Paramètres';
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';

  Future<String> _getStartingAmountForUser() async {
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
    }
    return double.parse(json.decode(response.body)["initialAmount"].toString())
        .toDouble()
        .toStringAsFixed(2);
  }

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
        body: FutureBuilder(
          future: _getStartingAmountForUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print("aled");
              startingAmountAccount = snapshot.data as String;
              return settingsPage();
            }
            return const CircularProgressIndicator();
          },
        ));
  }

  Future<void> updateStartingAmountForUser(
    String amount,
  ) async {
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.post(
        Uri.parse("$serverUrl/updateInitialAmount/$userId?amount=$amount"));
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }

  Widget settingsPage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuLayout(
            title: widget.title,
            deviceWidth: _deviceWidth,
            deviceHeight: _deviceHeight),
        SizedBox(
          width: _deviceWidth! * 0.85,
          height: _deviceHeight! * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                width: _deviceWidth! * 0.4,
                child: Column(
                  children: [
                    Text(
                      "Le montant initial est le montant à partir duquel vos statistiques seront calculées en fonction des transactions que vous créerez"
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: _deviceWidth! * 0.01,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      // inputFormatters: <TextInputFormatter>[
                      //   FilteringTextInputFormatter.allow(
                      //       RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                      // ],
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      initialValue: startingAmountAccount,
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: _deviceWidth! * 0.018,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: ((value) {
                        double bmax =
                            BigInt.parse("9223372036854775807").toDouble();
                        double bmin =
                            BigInt.parse("-9223372036854775807").toDouble();
                        if (value.contains(",")) {
                          value =
                              "${value.substring(0, value.indexOf(","))}.${value.substring(value.indexOf(",") + 1)}";
                          startingAmountAccount = value;
                        } else if (double.parse(value) >= bmax) {
                          value = bmax.toString();
                          showToast(context, Text("Max value is $bmax"));
                        } else if (double.parse(value) <= bmin) {
                          value = bmin.toString();
                          showToast(context, Text("Min value is $bmin"));
                        } else if (value.trim() != "") {
                          startingAmountAccount =
                              double.parse(value).toDouble().toStringAsFixed(2);
                        }
                      }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: _deviceHeight! * 0.05),
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
        ),
      ],
    );
  }
}
