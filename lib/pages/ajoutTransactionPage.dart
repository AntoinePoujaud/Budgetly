// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/Enum/PaymentMethodEnum.dart';
import 'package:budgetly/models/AllCategories.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String? _paymentMethodGroupValue = PaymentMethodEnum.CBRETRAIT;
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  List<AllCategories>? dropDownItems = [];
  AllCategories? selectedItem;
  TextEditingController categNameTxt = TextEditingController();

  String? transactionType;
  String? paymentMethod = PaymentMethodEnum.CBRETRAIT;
  double? montant;
  DateTime? currentDate;
  String? description;
  String? categorie = CategorieEnum.LOISIRS;
  // String serverUrl = 'https://moneytly.herokuapp.com';
  String serverUrl = 'http://localhost:8081';

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
      backgroundColor: "#CCE4DD".toColor(),
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
          height: _deviceHeight! * 1,
          width: _deviceWidth! * 0.85,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  color: "#0A454A".toColor(),
                  width: _deviceWidth! * 0.85,
                  height: _deviceHeight! * 0.2,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    left: _deviceWidth! * 0.05,
                    right: _deviceWidth! * 0.05,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Remplissez -".toUpperCase(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: _deviceWidth! * 0.015,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        selectTransactionWidget(0.012, 0.12),
                        Container(
                          color: Colors.white,
                          height: 1,
                          width: _deviceWidth! * 0.7,
                          alignment: Alignment.center,
                        ),
                        selectPaymentMethodWidget(0.011, 0.12),
                      ]),
                ),
                Container(
                  height: _deviceHeight! * 0.55,
                  width: _deviceWidth! * 0.85,
                  padding: EdgeInsets.only(
                    left: _deviceWidth! * 0.05,
                    right: _deviceWidth! * 0.05,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        categorieSelectionWidget(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            descriptionWidget(),
                            montantWidget(),
                          ],
                        ),
                        dateSelectionWidget(),
                      ]),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: _deviceHeight! * 0.05),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(25.0),
                      backgroundColor: "#EC6463".toColor(),
                    ),
                    child: Text(
                      'label_save_transaction'.i18n().toUpperCase(),
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: _deviceWidth! * 0.018,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      if (transactionType == null) {
                        showToast(context,
                            const Text("Please select a transaction type"));
                      } else {
                        try {
                          await addTransaction([
                            currentDate,
                            transactionType,
                            double.parse(montant!.toStringAsFixed(2)),
                            description,
                            selectedItem!.id,
                            paymentMethod
                          ]);

                          resetAllValues();
                          // ignore: use_build_context_synchronously
                          showToast(context,
                              const Text("Transaction added successfully"));
                        } catch (e) {
                          showToast(context,
                              const Text("Error while adding transaction"));
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget selectTransactionWidget(double fontSize, double boxWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          radioButtonLabelledTransactions(
              'label_depense'.i18n(),
              TransactionEnum.DEPENSE,
              _groupValue,
              fontSize,
              boxWidth,
              'transaction'),
          SizedBox(
            width: _deviceWidth! * 0.005,
          ),
          radioButtonLabelledTransactions(
              'label_revenu'.i18n(),
              TransactionEnum.REVENU,
              _groupValue,
              fontSize,
              boxWidth,
              'transaction'),
        ],
      ),
    );
  }

  Widget selectPaymentMethodWidget(double fontSize, double boxWidth) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        radioButtonLabelledTransactions(
            _deviceWidth! > 1600
                ? 'label_cbretrait'.i18n()
                : 'label_cbretrait_short'.i18n(),
            PaymentMethodEnum.CBRETRAIT,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            _deviceWidth! > 1600
                ? 'label_cbcommerces'.i18n()
                : 'label_cbcommerces_short'.i18n(),
            PaymentMethodEnum.CBCOMMERCES,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            _deviceWidth! > 1600
                ? 'label_cheque'.i18n()
                : 'label_cheque_short'.i18n(),
            PaymentMethodEnum.CHEQUE,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            _deviceWidth! > 1600
                ? 'label_virement'.i18n()
                : 'label_virement_short'.i18n(),
            PaymentMethodEnum.VIREMENT,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            _deviceWidth! > 1600
                ? 'label_prelevement'.i18n()
                : 'label_prelevement_short'.i18n(),
            PaymentMethodEnum.PRELEVEMENT,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            _deviceWidth! > 1600
                ? 'label_paypal'.i18n()
                : 'label_paypal_short'.i18n(),
            PaymentMethodEnum.PAYPAL,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
      ],
    );
  }

  Widget descriptionWidget() {
    return SizedBox(
      width: customTransactionInputWidth(0.4),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'label_enter_desc'.i18n().toUpperCase(),
          labelStyle: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 95, 95, 95),
            fontSize: _deviceWidth! * 0.018,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: GoogleFonts.roboto(
          color: Colors.black,
          fontSize: _deviceWidth! * 0.018,
          fontWeight: FontWeight.w700,
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
      width: customTransactionInputWidth(0.4),
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
        ],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'label_enter_amount'.i18n().toUpperCase(),
          labelStyle: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 95, 95, 95),
            fontSize: _deviceWidth! * 0.018,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: GoogleFonts.roboto(
          color: Colors.black,
          fontSize: _deviceWidth! * 0.018,
          fontWeight: FontWeight.w700,
        ),
        onChanged: ((value) {
          setState(() {
            double bmax = BigInt.parse("9223372036854775807").toDouble();
            double bmin = BigInt.parse("-9223372036854775807").toDouble();
            if (double.parse(value) >= bmax) {
              montant = bmax;
              showToast(context, Text("Max value is $bmax"));
            } else if (double.parse(value) <= bmin) {
              montant = bmin;
              showToast(context, Text("Min value is $bmin"));
            } else if (value.contains(",")) {
              value =
                  "${value.substring(0, value.indexOf(","))}.${value.substring(value.indexOf(",") + 1)}";
            } else if (value.trim() != "") {
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
      width: customTransactionInputWidth(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Sélectionnez - ".toUpperCase(),
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: _deviceWidth! * 0.015,
              fontWeight: FontWeight.w700,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black,
            ),
            onPressed: () async {
              DateTime? newDate = await showDatePicker(
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: "#EC6463".toColor(),
                        onPrimary: Colors.black,
                        surface: "#0A454A".toColor(),
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: "#CCE4DD".toColor(),
                    ),
                    child: child!,
                  );
                },
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
              '${date.day < 10 ? '0${date.day}' : date.day}/${date.month < 10 ? '0${date.month}' : date.month}/${date.year}',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: _deviceWidth! * 0.018,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AllCategories findCategFromId(String id) {
    for (AllCategories category in dropDownItems!) {
      if (category.id.toString() == id) {
        return category;
      }
    }
    return dropDownItems![0];
  }

  Widget categorieSelectionWidget() {
    return SizedBox(
      width: customTransactionInputWidth(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: customTransactionInputWidth(0.19),
            child: DropdownButton<String>(
              dropdownColor: "#EC6463".toColor(),
              value: selectedItem!.id.toString(),
              underline: Container(
                height: 1,
                color: Colors.black,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              onChanged: (value) {
                setState(() {
                  selectedItem = findCategFromId(value!);
                });
              },
              items: dropDownItems!
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Row(
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: _deviceWidth! * 0.018,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: _deviceWidth! * 0.015,
                          ),
                          item.id > 6
                              ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: Colors.grey.shade900),
                                    onPressed: () async {
                                      try {
                                        deleteCateg(item.id);
                                        showToast(
                                            context,
                                            const Text(
                                                "Category deleted successfully"));
                                          resetAllValues();
                                      } catch (e) {
                                        showToast(
                                            context,
                                            const Text(
                                                "Error while deleting Category"));
                                      }
                                    },
                                  ),
                                )
                              : const Text("")
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(
            height: _deviceHeight! * 0.01,
          ),
          Row(
            children: [
              SizedBox(
                width: customTransactionInputWidth(0.12),
                height: _deviceHeight! * 0.035,
                child: TextFormField(
                  controller: categNameTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'label_add_categ'.i18n().toUpperCase(),
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 95, 95, 95),
                      fontSize: _deviceWidth! * 0.01,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _deviceWidth! * 0.01,
                    fontWeight: FontWeight.w700,
                  ),
                  onChanged: ((value) {
                    setState(() {
                      description = value;
                    });
                  }),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 62, 168, 62),
                  ),
                  onPressed: () async {
                    if (categNameTxt.text == "") {
                      showToast(context, const Text("Please enter some text"));
                      return;
                    }
                    try {
                      addCategory(categNameTxt.text);
                      showToast(
                          context, const Text("Category added successfully"));
                      resetAllValues();
                    } catch (e) {
                      showToast(
                          context, const Text("Error while adding Category"));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> addCategory(String categName) async {
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.post(Uri.parse(
        "$serverUrl/addCategorie?userId=$userId&name=${categName.toUpperCase()}"));
    if (response.statusCode != 201) {}
  }

  Widget radioButtonLabelledTransactions(
    String title,
    String value,
    String? groupValue,
    double fontSize,
    double boxWidth,
    String groupName,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _deviceWidth! * boxWidth,
        maxHeight: _deviceHeight! * 0.8,
      ),
      child: ListTile(
        title: Text(
          title.toUpperCase(),
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: _deviceWidth! * fontSize,
            fontWeight: FontWeight.w700,
          ),
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
                if (groupName == 'paymentMethod') {
                  _paymentMethodGroupValue = value;
                  paymentMethod = value;
                } else {
                  _groupValue = value;
                  transactionType = value;
                }
              });
            }),
      ),
    );
  }

  TextStyle customTextStyle(double fontSize) {
    return TextStyle(
      color: Colors.white,
      fontSize: _deviceWidth! * fontSize,
    );
  }

  double customTransactionInputWidth(percentage) {
    return _deviceWidth! * percentage;
  }

  Future<List<AllCategories>> getAllCategories() async {
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    List<AllCategories> allCategories = [];
    var response =
        await http.get(Uri.parse("$serverUrl/getCategories?userId=$userId"));
    if (json.decode(response.body) != null) {
      for (var i = 0; i < json.decode(response.body).length; i++) {
        AllCategories category = AllCategories(
            id: json.decode(response.body)[i]["id"],
            name: json.decode(response.body)[i]["name"]);
        allCategories.add(category);
      }
      allCategories.sort((a, b) {
        return a.name[0].toLowerCase().compareTo(b.name[0].toLowerCase());
      });
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
        "$serverUrl/addTransaction?date=${params[0].year}-${params[0].month}-${params[0].day}&type=${params[1]}&amount=${params[2]}&description=${params[3]}&catId=${params[4]}&userId=$userId&paymentMethod=${params[5]}"));
    if (response.statusCode != 201) {}
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }

  void resetAllValues() {
    Navigator.popAndPushNamed(context, "/addTransaction");
  }

  Future<void> deleteCateg(int catId) async {
    var response = await http.post(
        Uri.parse("$serverUrl/deleteCategorie?catId=${catId.toString()}"));
    if (response.statusCode != 200) {}
  }
}
