// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/Enum/MonthEnum.dart';
import 'package:budgetly/Enum/PaymentMethodEnum.dart';
import 'package:budgetly/models/AllCategories.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enum/TransactionEnum.dart';
import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  AddTransactionState createState() => AddTransactionState();
}

class AddTransactionState extends State<AddTransaction> {
  double? _deviceHeight, _deviceWidth;
  String _groupValue = TransactionEnum.NONE;
  String? _paymentMethodGroupValue = PaymentMethodEnum.CBRETRAIT;
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  List<AllCategories>? dropDownItems = [];
  AllCategories? selectedItem;
  TextEditingController categNameTxt = TextEditingController();
  List<int> years = [];
  int currentYear = DateTime.now().year;
  int? initialYear;
  int? initialMonth;
  List<String> filterMonthYears = [];
  List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  int currentMonthId = MonthEnum().getIdFromString(
      DateFormat.MMMM("en").format(DateTime.now()).toLowerCase());

  String? transactionType;
  String? paymentMethod = PaymentMethodEnum.CBRETRAIT;
  double? montant;
  DateTime? currentDate;
  String? description;
  String? categorie = CategorieEnum.LOISIRS;
  bool isMobile = false;
  bool isDesktop = false;
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';

  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    Utils.checkIfConnected(context).then((value) {
      if (value) {
        isConnected = true;
        years = [currentYear - 1, currentYear, currentYear + 1];
        initialMonth = currentMonthId;
        initialYear = currentYear;
        for (int i = currentYear - 1; i <= currentYear + 1; i++) {
          for (int j = (i > currentYear - 1 ? 1 : currentMonthId);
              j <= (i == currentYear + 1 ? currentMonthId : months.length);
              j++) {
            filterMonthYears.add("$j $i");
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    isMobile = _deviceWidth! < 768;
    isDesktop = _deviceWidth! > 1024;
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
        isMobile
            ? const Text("")
            : MenuLayout(
                title: widget.title,
                deviceWidth: _deviceWidth,
                deviceHeight: _deviceHeight),
        SizedBox(
          height: _deviceHeight! * 1,
          width: isMobile ? _deviceWidth : _deviceWidth! * 0.85,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  color: "#0A454A".toColor(),
                  width: isMobile ? _deviceWidth : _deviceWidth! * 0.85,
                  height: _deviceHeight! * 0.25,
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
                        Row(
                          mainAxisAlignment: isMobile
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            isMobile
                                ? mobileMenu()
                                : const SizedBox(
                                    height: 0,
                                    width: 0,
                                  ),
                            Text(
                              "add_transaction_title".i18n().toUpperCase(),
                              textAlign: TextAlign.start,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: isMobile
                                    ? _deviceWidth! * 0.055
                                    : _deviceWidth! * 0.015,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        isMobile
                            ? selectTransactionWidget(0.035, 0.2)
                            : selectTransactionWidget(0.012, 0.12),
                        Container(
                          // color: Colors.white,
                          height: 1,
                          // width: _deviceWidth! * 0.7,
                        ),
                        isMobile
                            ? selectPaymentMethodWidget(0.03, 0.12)
                            : selectPaymentMethodWidget(0.009, 0.1),
                      ]),
                ),
                Container(
                  height: _deviceHeight! * 0.55,
                  width: isMobile ? _deviceWidth : _deviceWidth! * 0.85,
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
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return "#dc6c68".toColor(); //<-- SEE HERE
                          }
                          return null; // Defer to the widget's default.
                        },
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(25.0)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text(
                      'label_save_transaction'.i18n().toUpperCase(),
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: isMobile
                            ? _deviceWidth! * 0.06
                            : _deviceWidth! * 0.018,
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

  Widget mobileMenu() {
    return PopupMenuButton(
      color: "#133543".toColor(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(children: [
            Icon(
              Icons.home,
              color: widget.title == 'tableau_recap_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'tableau_recap_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'tableau_recap_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/homepage");
            widget.title != 'tableau_recap_title'.i18n()
                ? Navigator.of(context).pushNamed("/homepage")
                : "";
          },
        ),
        PopupMenuItem(
          value: 1,
          child: Row(children: [
            Icon(
              Icons.add,
              color: widget.title == 'add_transaction_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'add_transaction_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'add_transaction_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/addTransaction");
            widget.title != 'add_transaction_title'.i18n()
                ? Navigator.of(context).pushNamed("/addTransaction")
                : "";
          },
        ),
        PopupMenuItem(
          value: 2,
          child: Row(children: [
            Icon(
              Icons.manage_search,
              color: widget.title == 'tableau_general_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'tableau_general_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'tableau_general_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/transactions");
            widget.title != 'tableau_general_title'.i18n()
                ? Navigator.of(context).pushNamed("/transactions")
                : "";
          },
        ),
        PopupMenuItem(
          value: 3,
          child: Row(children: [
            Icon(
              Icons.settings,
              color: widget.title == 'settings_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'settings_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'settings_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/settings");
            widget.title != 'settings_title'.i18n()
                ? Navigator.of(context).pushNamed("/settings")
                : "";
          },
        ),
        PopupMenuItem(
          value: 4,
          child: Row(children: [
            const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            Text(
              'label_disconnect'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ]),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("userId", "");
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamed("/login");
          },
        ),
      ],
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
      ),
    );
  }

  Widget selectTransactionWidget(double fontSize, double boxWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                transactionType = TransactionEnum.DEPENSE;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 45, right: 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: transactionType == TransactionEnum.DEPENSE
                  ? Colors.grey
                  : "#dc6c68".toColor(),
            ),
            child: Text(
              "enum_label_depense".i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: _deviceWidth! * fontSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                transactionType = TransactionEnum.REVENU;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 55, right: 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: transactionType == TransactionEnum.REVENU
                  ? Colors.grey
                  : "#133543".toColor(),
            ),
            child: Text(
              "enum_label_revenu".i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: _deviceWidth! * fontSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectPaymentMethodWidget(double fontSize, double boxWidth) {
    return Wrap(
      spacing: 0,
      alignment: WrapAlignment.start,
      crossAxisAlignment:
          isMobile ? WrapCrossAlignment.center : WrapCrossAlignment.start,
      children: [
        radioButtonLabelledTransactions(
            isDesktop
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
            isDesktop
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
            isDesktop ? 'label_cheque'.i18n() : 'label_cheque_short'.i18n(),
            PaymentMethodEnum.CHEQUE,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            isDesktop ? 'label_virement'.i18n() : 'label_virement_short'.i18n(),
            PaymentMethodEnum.VIREMENT,
            _paymentMethodGroupValue,
            fontSize,
            boxWidth,
            'paymentMethod'),
        SizedBox(
          width: _deviceWidth! * 0.005,
        ),
        radioButtonLabelledTransactions(
            isDesktop
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
            isDesktop ? 'label_paypal'.i18n() : 'label_paypal_short'.i18n(),
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
      width: isMobile
          ? customTransactionInputWidth(1)
          : customTransactionInputWidth(0.25),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'label_enter_desc'.i18n().toUpperCase(),
          labelStyle: GoogleFonts.roboto(
            // color: const Color.fromARGB(255, 95, 95, 95),
            color: Colors.black,
            fontSize: isMobile ? _deviceWidth! * 0.06 : _deviceWidth! * 0.018,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: GoogleFonts.roboto(
          color: Colors.black,
          fontSize: isMobile ? _deviceWidth! * 0.06 : _deviceWidth! * 0.018,
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
      width: isMobile
          ? customTransactionInputWidth(1)
          : customTransactionInputWidth(0.25),
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
        ],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'label_enter_amount'.i18n().toUpperCase(),
          labelStyle: GoogleFonts.roboto(
            // color: const Color.fromARGB(255, 95, 95, 95),
            color: Colors.black,
            fontSize: isMobile ? _deviceWidth! * 0.06 : _deviceWidth! * 0.018,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: GoogleFonts.roboto(
          color: Colors.black,
          fontSize: isMobile ? _deviceWidth! * 0.06 : _deviceWidth! * 0.018,
          fontWeight: FontWeight.w700,
        ),
        onChanged: ((value) {
          setState(() {
            double bmax = BigInt.parse("9223372036854775807").toDouble();
            double bmin = BigInt.parse("-9223372036854775807").toDouble();
            if (value.contains(",")) {
              montant = double.parse(
                  "${value.substring(0, value.indexOf(","))}.${value.substring(value.indexOf(",") + 1)}");
            } else if (double.parse(value) >= bmax) {
              montant = bmax;
              showToast(context, Text("Max value is $bmax"));
            } else if (double.parse(value) <= bmin) {
              montant = bmin;
              showToast(context, Text("Min value is $bmin"));
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
      width: isMobile
          ? customTransactionInputWidth(1)
          : customTransactionInputWidth(0.25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text(
          //   "Sélectionnez - ".toUpperCase(),
          //   style: GoogleFonts.roboto(
          //     color: Colors.black,
          //     fontSize: _deviceWidth! * 0.015,
          //     fontWeight: FontWeight.w700,
          //   ),
          // ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: isMobile
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(20),
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
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                context: context,
                initialDate: date,
                firstDate: DateTime(initialYear! - 1, initialMonth!),
                lastDate: DateTime(initialYear! + 1, initialMonth!),
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
                fontSize:
                    isMobile ? _deviceWidth! * 0.06 : _deviceWidth! * 0.018,
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
      width: isMobile
          ? customTransactionInputWidth(1)
          : customTransactionInputWidth(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            width: isMobile
                ? customTransactionInputWidth(1)
                : customTransactionInputWidth(0.19),
            height: isMobile ? 30 : 50,
            child: DropdownButton<String>(
              dropdownColor: "#EC6463".toColor(),
              value: selectedItem!.id.toString(),
              underline: Container(
                height: 0,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: isMobile
                                  ? _deviceWidth! * 0.06
                                  : _deviceWidth! * 0.018,
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
                                    padding: const EdgeInsets.all(0),
                                    iconSize: 20,
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
                width: isMobile
                    ? customTransactionInputWidth(0.55)
                    : customTransactionInputWidth(0.12),
                height: _deviceHeight! * 0.035,
                child: TextFormField(
                  controller: categNameTxt,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'label_add_categ'.i18n().toUpperCase(),
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 95, 95, 95),
                      fontSize: isMobile
                          ? _deviceWidth! * 0.04
                          : _deviceWidth! * 0.01,
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
                    // color: Color.fromARGB(255, 62, 168, 62),
                    color: Color.fromARGB(255, 95, 95, 95),
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
    String token = Utils.getCookieValue("token");
    var response = await http.post(
        Uri.parse(
            "$serverUrl/addCategorie?userId=$userId&name=${categName.toUpperCase()}"),
        headers: {'Authorization': 'Bearer $token'});
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
    return SizedBox(
      width: isMobile ? _deviceWidth! / 3.5 : _deviceWidth! / 6,
      height: 50,
      // constraints: BoxConstraints(
      //   maxWidth: _deviceWidth! * boxWidth,
      //   maxHeight: _deviceHeight! * 0.8,
      // ),
      child: ListTile(
        title: Text(
          title.toUpperCase(),
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: _deviceWidth! * fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        contentPadding: const EdgeInsets.all(5),
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
                  _groupValue = value!;
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
    String token = Utils.getCookieValue("token");
    var response = await http.get(
        Uri.parse("$serverUrl/getCategories?userId=$userId"),
        headers: {'Authorization': 'Bearer $token'});
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
    String token = Utils.getCookieValue("token");
    var response = await http.post(
        Uri.parse(
            "$serverUrl/addTransaction?date=${params[0].year}-${params[0].month}-${params[0].day}&type=${params[1]}&amount=${params[2]}&description=${params[3]}&catId=${params[4]}&userId=$userId&paymentMethod=${params[5]}"),
        headers: {'Authorization': 'Bearer $token'});
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
    String token = Utils.getCookieValue("token");
    var response = await http.post(
        Uri.parse("$serverUrl/deleteCategorie?catId=${catId.toString()}"),
       headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) {}
  }
}
