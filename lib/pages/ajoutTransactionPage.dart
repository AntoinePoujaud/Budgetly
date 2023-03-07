// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/models/AllCategories.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enum/TransactionEnum.dart';
import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class AjoutTransaction extends StatefulWidget {
  const AjoutTransaction({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  AjoutTransactionState createState() => AjoutTransactionState();
}

class AjoutTransactionState extends State<AjoutTransaction> {
  double? _deviceHeight, _deviceWidth;
  String? _groupValue = TransactionEnum.NONE;
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  List<AllCategories>? dropDownItems = [];
  AllCategories? selectedItem;

  String? transactionType;
  double? montant;
  DateTime? currentDate;
  String? description;
  String? categorie = CategorieEnum.LOISIRS;
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';

  @override
  void initState() {
    super.initState();
    Utils.checkIfConnected(context);
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    currentDate = date;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 23, 26),
      body: showForm(),
    );
  }

  Widget showForm() {
    if (dropDownItems!.isEmpty) {
      return FutureBuilder(
        future: getAllCategories(),
        builder: (BuildContext context,
            AsyncSnapshot<List<AllCategories>> snapshot) {
          if (snapshot.hasData) {
            dropDownItems = snapshot.data;
            selectedItem = dropDownItems![0];
            return pageWidget();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return pageWidget();
    }
  }

  Widget pageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        MenuLayout(
            title: widget.title,
            deviceWidth: _deviceWidth,
            deviceHeight: _deviceHeight),
        SizedBox(
          height: _deviceHeight! * 0.8,
          width: _deviceWidth! * 0.85,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                selectTransactionWidget(),
                categorieSelectionWidget(),
                montantWidget(),
                dateSelectionWidget(),
                descriptionWidget(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(25.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    backgroundColor: const Color.fromARGB(255, 29, 161, 242),
                  ),
                  child: Text(
                    'label_save_transaction'.i18n(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _deviceWidth! * 0.02,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await addTransaction([
                        currentDate,
                        transactionType,
                        double.parse(montant!.toStringAsFixed(2)),
                        description,
                        CategorieEnum()
                            .getIdFromEnum(context, selectedItem!.name),
                      ]);

                      resetAllValues();
                      // ignore: use_build_context_synchronously
                      showToast(context,
                          const Text("Transaction added successfully"));
                    } catch (e) {
                      showToast(context,
                          const Text("Error while adding transaction"));
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget selectTransactionWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        radioButtonLabelledTransactions(
            'label_depense'.i18n(), TransactionEnum.DEPENSE, _groupValue),
        SizedBox(
          width: _deviceWidth! * 0.2,
        ),
        radioButtonLabelledTransactions(
            'label_revenu'.i18n(), TransactionEnum.REVENU, _groupValue),
      ],
    );
  }

  Widget descriptionWidget() {
    return SizedBox(
      width: customTransactionInputWidth(),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'label_enter_desc'.i18n().toUpperCase(),
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
            description = value;
          });
        }),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }

  Widget montantWidget() {
    return SizedBox(
      width: customTransactionInputWidth(),
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
        ],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'label_enter_amount'.i18n().toUpperCase(),
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
            if (value.contains(",")) {
              value =
                  "${value.substring(0, value.indexOf(","))}.${value.substring(value.indexOf(",") + 1)}";
            }
            if (value.trim() != "") {
              montant = double.parse(value);
            }
          });
        }),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }

  Widget dateSelectionWidget() {
    return SizedBox(
      width: customTransactionInputWidth(),
      child: Row(
        children: [
          Text(
            '${date.day < 10 ? '0${date.day}' : date.day}/${date.month < 10 ? '0${date.month}' : date.month}/${date.year}',
            style: TextStyle(
              color: Colors.white,
              fontSize: _deviceWidth! * 0.015,
            ),
          ),
          SizedBox(
            width: _deviceWidth! * 0.05,
            height: _deviceHeight! * 0.01,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(25.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              backgroundColor: const Color.fromARGB(255, 29, 161, 242),
            ),
            onPressed: () async {
              DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2022),
                lastDate: DateTime(2030),
              );

              if (newDate == null) return;
              setState(() {
                date = newDate;
                currentDate = newDate;
              });
            },
            child: Text(
              'label_select_date_transaction'.i18n(),
              style: TextStyle(
                  color: Colors.white, fontSize: _deviceWidth! * 0.012),
            ),
          ),
        ],
      ),
    );
  }

  Widget categorieSelectionWidget() {
    return SizedBox(
      width: customTransactionInputWidth(),
      child: DropdownButton<String>(
        dropdownColor: const Color.fromARGB(255, 54, 54, 54),
        value: selectedItem!.name,
        onChanged: (value) {
          setState(() {
            List<AllCategories>? temp = [];
            selectedItem!.name = value.toString();
            dropDownItems!.removeWhere((element) => element == selectedItem);
            temp.add(selectedItem!);
            //Sort List alphabetically
            dropDownItems!.sort((a, b) {
              return a.name[0].toLowerCase().compareTo(b.name[0].toLowerCase());
            });
            temp.addAll(dropDownItems!);
            dropDownItems = temp;
          });
        },
        items: dropDownItems!
            .map((item) => 
                  // if (item.type == _groupValue || item.type == "BOTH") {
                  DropdownMenuItem<String>(
                    value: item.name,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _deviceWidth! * 0.013,
                      ),
                    ),
                  ),
                  // } else {

                  // }
                )
            .toList(),
      ),
    );
  }

  Widget radioButtonLabelledTransactions(
    String title,
    String value,
    String? groupValue,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _deviceWidth! * 0.12,
        maxHeight: _deviceHeight! * 0.8,
      ),
      child: ListTile(
        title: Text(
          title,
          style: customTextStyle(),
        ),
        leading: Radio<String>(
            fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.orange.withOpacity(.32);
              }
              return Colors.white;
            }),
            value: value,
            groupValue: groupValue,
            onChanged: (String? value) {
              setState(() {
                _groupValue = value;
                transactionType = value;
              });
            }),
      ),
    );
  }

  TextStyle customTextStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: _deviceWidth! * 0.011,
    );
  }

  double customTransactionInputWidth() {
    return _deviceWidth! * 0.5;
  }

  Future<List<AllCategories>> getAllCategories() async {
    List<AllCategories> allCategories = [];
    var response = await http.get(Uri.parse("$serverUrl/getCategories"));
    if (json.decode(response.body) != null) {
      for (var i = 0; i < json.decode(response.body).length; i++) {
        AllCategories category = AllCategories(
            id: 0,
            name: json.decode(response.body)[i]["name"],
            type: json.decode(response.body)[i]["type"]);
        allCategories.add(category);
      }
      return allCategories;
    }
    return [];
  }

  Future<void> addTransaction(List<dynamic> params) async {
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }

    var response = await http.post(Uri.parse(
        "$serverUrl/addTransaction?date=${params[0].year}-${params[0].month}-${params[0].day}&type=${params[1]}&amount=${params[2]}&description=${params[3]}&catId=${params[4]}&userId=$userId"));
    if (response.statusCode != 201) {
      // throw Exception();
    }
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }

  void resetAllValues() {
    Navigator.popAndPushNamed(context, "/addTransaction");
  }
}
