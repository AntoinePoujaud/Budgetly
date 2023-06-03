// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/Enum/FilterGeneralEnum.dart';
import 'package:budgetly/Enum/TransactionEnum.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enum/MonthEnum.dart';
import '../Enum/PaymentMethodEnum.dart';
import '../models/AllCategories.dart';
import '../models/TransactionByMonthAndYear.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  TransactionsState createState() => TransactionsState();
}

class TransactionsState extends State<Transactions> {
  double? _deviceHeight, _deviceWidth;
  double currentAmount = 0;
  double currentRealAmount = 0;
  String _groupValue = FilterGeneralEnum.LAST;
  List<Map<String, String?>> resultTransactions = [];
  DateTime date = DateTime.now();
  List<AllCategories>? dropDownItems = [];
  final _formKey = GlobalKey<FormState>();

  AllCategories? selectedItem;
  String? description;
  String? transactionType;
  String? paymentMethod;
  double? montant;
  DateTime? currentDate;
  String? _groupValueTransaction;
  String? _groupValuePaymentMethod;
  String? selectedTileId;

  bool isMobile = false;
  bool isDesktop = false;

  TextEditingController descriptionTxt = TextEditingController();
  TextEditingController montantTxt = TextEditingController();
  TextEditingController categNameTxt = TextEditingController();

  List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  int currentMonthId = MonthEnum().getIdFromString(
      DateFormat.MMMM("en").format(DateTime.now()).toLowerCase());
  List<int> years = [2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030];
  int currentYear = DateTime.now().year;
  int? initialYear;
  int? initialMonth;
  List<String> filterMonthYears = [];
  bool isConnected = false;

  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';
  @override
  void initState() {
    super.initState();
    Utils.checkIfConnected(context).then(
      (value) {
        if (value) {
          isConnected = true;
          getTransactionsForMonthAndYear();
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      _deviceHeight = MediaQuery.of(context).size.height;
      _deviceWidth = MediaQuery.of(context).size.width;
      isMobile = _deviceWidth! < 768;
      isDesktop = _deviceWidth! > 1024;
      return Visibility(
        child: Scaffold(
          backgroundColor: "#CCE4DD".toColor(),
          body: showPage(),
        ),
      );
    }
    return const Scaffold();
  }

  Widget showPage() {
    return pageWidget();
  }

  Widget pageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? const Text("")
            : MenuLayout(
                title: widget.title,
                deviceWidth: _deviceWidth,
                deviceHeight: _deviceHeight),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              color: "#0A454A".toColor(),
              width: isMobile ? _deviceWidth : _deviceWidth! * 0.85,
              height: _deviceHeight! * 0.1,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  isMobile
                      ? mobileMenu()
                      : const SizedBox(
                          height: 0,
                          width: 0,
                        ),
                  generalCurrentInformations(
                      isMobile
                          ? "Compte :".toUpperCase()
                          : 'actual_amount'.i18n().toUpperCase(),
                      currentAmount.toStringAsFixed(2)),
                  generalCurrentInformations(
                      isMobile
                          ? "Réel :".toUpperCase()
                          : 'real_amount'.i18n().toUpperCase(),
                      currentRealAmount.toStringAsFixed(2)),
                ],
              ),
            ),
            SizedBox(
              width: isMobile ? _deviceWidth! : _deviceWidth! * 0.82,
              height: _deviceHeight! * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  selectMonthYearWidget(),
                  resultTransactions.isNotEmpty
                      ? (isMobile
                          ? transactionsNotNullWidgetMobile()
                          : transactionsNotNullWidget())
                      : noTransactionWidget()
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget transactionsNotNullWidgetMobile() {
    return Column(
      children: [
        Visibility(
          visible: selectedTileId == null ? true : false,
          child: transactionListWidget(),
        ),
        showForm(),
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

  Widget selectMonthYearWidget() {
    return SizedBox(
      width: _deviceWidth! * 0.79,
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Visibility(
            visible: (currentMonthId == initialMonth &&
                    currentYear == initialYear! - 1)
                ? false
                : true,
            child: IconButton(
              onPressed: () async {
                if (currentMonthId == 1) {
                  currentMonthId = 12;
                  currentYear = currentYear - 1;
                } else {
                  currentMonthId = currentMonthId - 1;
                }
                await getTransactionsForMonthAndYear();
                setState(() {});
              },
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
            ),
          ),
          DropdownButton<String>(
            dropdownColor: "#EC6463".toColor(),
            value: "${currentMonthId.toString()} ${currentYear.toString()}",
            onChanged: (value) {
              setState(() {
                currentMonthId = int.parse(value!.split(" ")[0]);
                currentYear = int.parse(value.split(" ")[1]);
                getTransactionsForMonthAndYear();
              });
            },
            items: filterMonthYears
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      "${MonthEnum().getStringFromId(int.parse(item.split(" ")[0]))} ${int.parse(item.split(" ")[1])}"
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isMobile
                            ? _deviceWidth! * 0.05
                            : _deviceWidth! * 0.013,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Visibility(
            visible: (currentMonthId == initialMonth &&
                    currentYear == initialYear! + 1)
                ? false
                : true,
            child: IconButton(
              onPressed: () async {
                if (currentMonthId == 12) {
                  currentMonthId = 1;
                  currentYear = currentYear + 1;
                } else {
                  currentMonthId = currentMonthId + 1;
                }
                await getTransactionsForMonthAndYear();
                setState(() {});
              },
              icon: const Icon(
                Icons.chevron_right,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionsNotNullWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            transactionListWidget(),
            showForm(),
          ],
        ),
      ],
    );
  }

  Widget noTransactionWidget() {
    return SizedBox(
      width: isMobile ? _deviceWidth! : _deviceWidth! * 0.75,
      height: _deviceHeight! * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Vous n'avez pas encore de transaction pour le mois de ${MonthEnum().getStringFromId(currentMonthId)} $currentYear",
              style: const TextStyle(color: Colors.black, fontSize: 45),
              textAlign: TextAlign.center,
            ),
            RichText(
              text: TextSpan(
                  text: "Ajouter une nouvelle transaction",
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 24,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pushNamed("/addTransaction");
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionListWidget() {
    return Container(
      margin: isMobile
          ? const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0)
          : const EdgeInsets.only(left: 40.0, top: 20.0),
      width: isMobile ? _deviceWidth! * 0.97 : _deviceWidth! * 0.40,
      height: _deviceHeight! * 0.78,
      child: Material(
        color: "#d0e3de".toColor(),
        child: ListView.builder(
          itemCount: resultTransactions.length,
          itemBuilder: (BuildContext context, int index) {
            String? newDate = formatDate(resultTransactions[index]["date"]!);
            return ListTile(
              onTap: () {
                setState(() {
                  selectedTileId = resultTransactions[index]["id"];
                  description = resultTransactions[index]["description"]!;
                  descriptionTxt.text =
                      resultTransactions[index]["description"]!;
                  montant = double.parse(resultTransactions[index]["amount"]!);
                  montantTxt.text = resultTransactions[index]["amount"]!;
                  transactionType = resultTransactions[index]["type"];
                  _groupValueTransaction = resultTransactions[index]["type"];
                  paymentMethod = resultTransactions[index]["paymentMethod"];
                  _groupValuePaymentMethod =
                      resultTransactions[index]["paymentMethod"];
                  date = DateTime.parse(resultTransactions[index]["date"]!);
                  selectedItem =
                      findCategFromId(resultTransactions[index]["catId"]!);
                });
              },
              tileColor:
                  resultTransactions[index]["type"] == TransactionEnum.REVENU
                      ? "#133543".toColor()
                      : "#dc6c68".toColor(),
              leading: const Icon(
                Icons.list,
                color: Colors.white,
              ),
              title: Text(
                resultTransactions[index]["description"]!.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 17,
                ),
              ),
              subtitle: Text(
                newDate!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 11 : 15,
                ),
              ),
              trailing: SizedBox(
                width: isMobile ? _deviceWidth! * 0.4 : _deviceWidth! * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: isMobile
                          ? _deviceWidth! * 0.09
                          : _deviceWidth! * 0.03,
                      child: Text(
                        PaymentMethodEnum().getShortLabel(
                            resultTransactions[index]['paymentMethod']!),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(
                      width: isMobile
                          ? _deviceHeight! * 0.02
                          : _deviceHeight! * 0.03,
                    ),
                    SizedBox(
                      width: isMobile
                          ? _deviceWidth! * 0.095
                          : _deviceWidth! * 0.06,
                      child: Text(
                        resultTransactions[index]['amount']!,
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(
                      width: isMobile
                          ? _deviceHeight! * 0.01
                          : _deviceHeight! * 0.03,
                    ),
                    SizedBox(
                      width: isMobile
                          ? _deviceWidth! * 0.15
                          : _deviceWidth! * 0.07,
                      child: Text(
                        resultTransactions[index]['catName']!,
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget updateTransactionSectionWidget() {
    return Visibility(
      visible: selectedTileId == null ? false : true,
      child: Container(
        margin: isMobile
            ? const EdgeInsets.only(left: 0.0, top: 0.0)
            : const EdgeInsets.only(left: 20.0, top: 20.0),
        padding: isMobile
            ? const EdgeInsets.only(top: 0.0, bottom: 0.0)
            : const EdgeInsets.only(top: 20.0, bottom: 20.0),
        width: isMobile ? _deviceWidth! : _deviceWidth! * 0.38,
        height: _deviceHeight! * 0.78,
        decoration: BoxDecoration(
          color: transactionType == TransactionEnum.DEPENSE
              ? "#dc6c68".toColor()
              : "#133543".toColor(),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              isMobile ? closeFormWidget() : const Text(""),
              selectTransactionWidget(0.01, 0.12),
              isMobile
                  ? selectPaymentMethodWidget(0.03, 0.3)
                  : selectPaymentMethodWidget(0.008, 0.09),
              categorieSelectionWidget(),
              descriptionWidget(),
              montantWidget(),
              dateSelectionWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
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
                      'label_delete_transaction'.i18n().toUpperCase(),
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: isMobile
                            ? _deviceWidth! * 0.05
                            : _deviceWidth! * 0.015,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        deleteTransaction(selectedTileId!);
                        showToast(context,
                            const Text("Transaction deleted successfully"));
                      } catch (e) {
                        showToast(context,
                            const Text("Error while deleting transaction"));
                      }
                    },
                  ),
                  ElevatedButton(
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
                            ? _deviceWidth! * 0.05
                            : _deviceWidth! * 0.015,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await updateTransaction([
                          date,
                          transactionType,
                          double.parse(montant!.toStringAsFixed(2)),
                          description,
                          // ignore: use_build_context_synchronously
                          selectedItem!.id,
                          selectedTileId,
                          paymentMethod,
                        ]);
                        resultTransactions = [];
                        await getTransactionsForMonthAndYear();
                        // ignore: use_build_context_synchronously
                        showToast(context,
                            const Text("Transaction updated successfully"));
                      } catch (e) {
                        showToast(context,
                            const Text("Error while updating transaction"));
                      }
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String? formatDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime convertedDate = dateFormat.parse(date);
    dateFormat = DateFormat("dd-MM-yyyy");
    return dateFormat.format(convertedDate);
  }

  Widget closeFormWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              iconSize: 20,
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () {
                selectedTileId = null;
                setState(() {});
              },
            ),
          ),
        ]);
  }

  Future<void> switchSectionVisibility(String? value) async {
    selectedTileId = value;
  }

  Widget radioButtonLabelledFilter(
    String title,
    String value,
    String? groupValue,
    String align,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _deviceWidth! * 0.15,
        maxHeight: _deviceHeight! * 0.1,
      ),
      child: ListTile(
        title: Text(
          title,
          style: customTextStyle(0.05),
          textAlign: align == "end" ? TextAlign.end : TextAlign.start,
        ),
        leading: Transform.scale(
          scale: 0.8,
          child: Radio<String>(
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
                  _groupValue = value!;
                });
              }),
        ),
      ),
    );
  }

  Widget generalCurrentInformations(String label, String value) {
    return SizedBox(
      width: isMobile
          ? _deviceWidth! / 3
          : _deviceWidth! *
              0.85 /
              2, // 2 est le nombre de homeCurrentInformations sur la même ligne
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: _deviceWidth! * 0.010,
          ),
          Text(
            "$value €",
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? _deviceWidth! * 0.04 : 32,
            ),
          ),
        ],
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

  Widget selectTransactionWidget(double fontSize, double boxWidth) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              transactionType = TransactionEnum.DEPENSE;
            });
          },
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 55, right: 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: transactionType == TransactionEnum.DEPENSE
                ? Colors.grey
                : "#dc6c68".toColor(),
          ),
          child: Text(
            "dépenses".toUpperCase(),
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize:
                    isMobile ? _deviceWidth! * 0.03 : _deviceWidth! * 0.015,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          width: 40,
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              transactionType = TransactionEnum.REVENU;
            });
          },
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 55, right: 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: transactionType == TransactionEnum.REVENU
                ? Colors.grey
                : "#133543".toColor(),
          ),
          child: Text(
            "revenus".toUpperCase(),
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize:
                    isMobile ? _deviceWidth! * 0.03 : _deviceWidth! * 0.015,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
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

  Widget descriptionWidget() {
    return SizedBox(
      width: isMobile ? _deviceWidth! * 0.8 : _deviceWidth! * 0.3,
      child: TextFormField(
        controller: descriptionTxt,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'label_enter_desc'.i18n().toUpperCase(),
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? _deviceWidth! * 0.04 : _deviceWidth! * 0.015,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? _deviceWidth! * 0.04 : _deviceWidth! * 0.015,
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
      width: isMobile ? _deviceWidth! * 0.8 : _deviceWidth! * 0.3,
      child: TextFormField(
        controller: montantTxt,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'label_enter_amount'.i18n().toUpperCase(),
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? _deviceWidth! * 0.04 : _deviceWidth! * 0.015,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? _deviceWidth! * 0.04 : _deviceWidth! * 0.015,
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
      width: isMobile ? _deviceWidth! * 0.8 : _deviceWidth! * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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

  Widget categorieSelectionWidget() {
    return SizedBox(
      width: isMobile ? _deviceWidth! * 0.8 : _deviceWidth! * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 1),
              ),
            ),
            width: isMobile ? _deviceWidth! * 0.47 : _deviceWidth! * 0.16,
            child: DropdownButton<String>(
              dropdownColor: "#EC6463".toColor(),
              value: selectedItem!.id.toString(),
              underline: Container(
                height: 0,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile
                                  ? _deviceWidth! * 0.04
                                  : _deviceWidth! * 0.013,
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
                width: isMobile ? _deviceWidth! * 0.47 : _deviceWidth! * 0.12,
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
                    color: Colors.white,
                    fontSize:
                        isMobile ? _deviceWidth! * 0.04 : _deviceWidth! * 0.01,
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

  void resetAllValues() {
    Navigator.popAndPushNamed(context, "/transactions");
  }

  Widget selectPaymentMethodWidget(double fontSize, double boxWidth) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            radioButtonLabelledTransactions(
                isMobile
                    ? 'label_cbretrait_short'.i18n()
                    : 'label_cbretrait'.i18n(),
                PaymentMethodEnum.CBRETRAIT,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            const SizedBox(
              width: 10,
            ),
            radioButtonLabelledTransactions(
                isMobile
                    ? 'label_cbcommerces_short'.i18n()
                    : 'label_cbcommerces'.i18n(),
                PaymentMethodEnum.CBCOMMERCES,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            const SizedBox(
              width: 10,
            ),
            radioButtonLabelledTransactions(
                isMobile ? 'label_cheque_short'.i18n() : 'label_cheque'.i18n(),
                PaymentMethodEnum.CHEQUE,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            radioButtonLabelledTransactions(
                isMobile
                    ? 'label_virement_short'.i18n()
                    : 'label_virement'.i18n(),
                PaymentMethodEnum.VIREMENT,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            const SizedBox(
              width: 10,
            ),
            radioButtonLabelledTransactions(
                isMobile
                    ? 'label_prelevement_short'.i18n()
                    : 'label_prelevement'.i18n(),
                PaymentMethodEnum.PRELEVEMENT,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            const SizedBox(
              width: 10,
            ),
            radioButtonLabelledTransactions(
                isMobile ? 'label_paypal_short'.i18n() : 'label_paypal'.i18n(),
                PaymentMethodEnum.PAYPAL,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
          ],
        ),
      ],
    );
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
          title,
          style: customTextStyle(fontSize),
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
                  _groupValuePaymentMethod = value;
                  paymentMethod = value;
                } else {
                  _groupValueTransaction = value;
                  transactionType = value;
                }
              });
            }),
      ),
    );
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
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
            return updateTransactionSectionWidget();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return updateTransactionSectionWidget();
    }
  }

  Future<void> deleteCateg(int catId) async {
    String token = Utils.getCookieValue("token");
    await http.post(
        Uri.parse("$serverUrl/deleteCategorie?catId=${catId.toString()}"),
        headers: {'Authorization': 'Bearer $token'});
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

  Future<void> _getMyInformations() async {
    String token = Utils.getCookieValue("token");
    String? userId = "";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.get(Uri.parse("$serverUrl/getAmounts/$userId"),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Error while getting informations"));
    }
    setState(() {
      currentAmount = double.parse(json
          .decode(response.body)["currentAmount"]
          .toDouble()
          .toStringAsFixed(2));
      currentRealAmount = double.parse(json
          .decode(response.body)["currentRealAmount"]
          .toDouble()
          .toStringAsFixed(2));
    });
  }

  Future<void> deleteTransaction(String id) async {
    String token = Utils.getCookieValue("token");
    var response = await http.post(
        Uri.parse("$serverUrl/deleteTransaction/$id"),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 204) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Error while deleting transaction"));
    }
    await getTransactionsForMonthAndYear();
  }

  Future<void> updateTransaction(List<dynamic> params) async {
    String token = Utils.getCookieValue("token");
    String? userId = "";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.post(
        Uri.parse(
            "$serverUrl/updateTransaction/${params[5]}?date=${params[0].year}-${params[0].month}-${params[0].day}&type=${params[1]}&amount=${params[2]}&description=${params[3]}&catId=${params[4]}&paymentMethod=${params[6]}&userId=$userId"),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Error while updating transaction"));
    }
  }

  Future<void> getTransactionsForMonthAndYear() async {
    resultTransactions = [];
    selectedTileId = null;
    String? userId = "";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    List<TransactionByMonthAndYear> fetchedTransactions =
        await fetchTransactions(userId);
    if (fetchedTransactions.isNotEmpty) {
      setState(() {
        for (TransactionByMonthAndYear transaction in fetchedTransactions) {
          resultTransactions.add(transaction.convertTransaction());
        }
      });
    } else {
      setState(() {});
    }
    _getMyInformations();
  }

  Future<List<TransactionByMonthAndYear>> fetchTransactions(
      String? userId) async {
    String token = Utils.getCookieValue("token");
    var response = await http.get(
        Uri.parse(
            "$serverUrl/getTransactionsForMonthAndYear?userId=$userId&selectedMonthId=$currentMonthId&selectedYear=$currentYear"),
        headers: {'Authorization': 'Bearer $token'});

    return json.decode(response.body) != null
        ? (json.decode(response.body) as List)
            .map((e) => TransactionByMonthAndYear.fromJson(e))
            .toList()
        : [];
  }

  Future<void> addCategory(String categName) async {
    String token = Utils.getCookieValue("token");
    String? userId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.post(
        Uri.parse(
            "$serverUrl/addCategorie?userId=$userId&name=${categName.toUpperCase()}"),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 201) {}
  }
}
