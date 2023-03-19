// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/Enum/FilterGeneralEnum.dart';
import 'package:budgetly/Enum/TransactionEnum.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enum/MonthEnum.dart';
import '../Enum/PaymentMethodEnum.dart';
import '../models/AllCategories.dart';
import '../models/TransactionByMonthAndYear.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  double? _deviceHeight, _deviceWidth;
  double? currentAmount;
  double? currentRealAmount;
  String? _groupValue = FilterGeneralEnum.LAST;
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

  TextEditingController descriptionTxt = TextEditingController();
  TextEditingController montantTxt = TextEditingController();

  List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  int currentMonthId = MonthEnum().getIdFromString(
      DateFormat.MMMM("en").format(DateTime.now()).toLowerCase());
  List<int> years = [2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030];
  int currentYear = DateTime.now().year;

  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';
  @override
  void initState() {
    super.initState();
    Utils.checkIfConnected(context);
    getTransactionsForMonthAndYear();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Visibility(
      child: Scaffold(
        backgroundColor: "#CCE4DD".toColor(),
        body: showPage(),
      ),
    );
  }

  Widget showPage() {
    if (currentAmount == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return pageWidget();
    }
  }

  Widget pageWidget() {
    return Row(
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
          children: <Widget>[
            Container(
              color: "#0A454A".toColor(),
              width: _deviceWidth! * 0.85,
              height: _deviceHeight! * 0.1,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  generalCurrentInformations(
                      'actual_amount'.i18n(), currentAmount.toString()),
                  generalCurrentInformations(
                      'real_amount'.i18n(), currentRealAmount.toString()),
                ],
              ),
            ),
            SizedBox(
              width: _deviceWidth! * 0.82,
              height: _deviceHeight! * 0.9,
              child: Column(
                children: [
                  selectMonthYearWidget(),
                  resultTransactions.isNotEmpty
                      ? transactionsNotNullWidget()
                      : noTransactionWidget()
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget selectMonthYearWidget() {
    return SizedBox(
      width: _deviceWidth! * 0.79,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            onPressed: () async {
              if (currentMonthId == 1) {
                currentMonthId = 12;
                if (currentYear == 2022) {
                  currentYear = years[years.length - 1];
                } else {
                  currentYear = currentYear - 1;
                }
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
          DropdownButton<String>(
            dropdownColor: "#EC6463".toColor(),
            value: currentMonthId.toString(),
            onChanged: (value) {
              setState(() {
                currentMonthId = int.parse(value!);
                getTransactionsForMonthAndYear();
              });
            },
            items: months
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      MonthEnum().getStringFromId(item),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: _deviceWidth! * 0.013,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            onPressed: () async {
              if (currentMonthId == 12) {
                currentMonthId = 1;
                if (currentYear == 2030) {
                  currentYear = years[0];
                } else {
                  currentYear = currentYear + 1;
                }
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
          IconButton(
            onPressed: () async {
              if (currentYear == 2022) {
                currentYear = years[years.length - 1];
              } else {
                currentYear = currentYear - 1;
              }
              await getTransactionsForMonthAndYear();
              setState(() {});
            },
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: "#EC6463".toColor(),
            value: currentYear.toString(),
            onChanged: (value) {
              setState(() {
                currentYear = int.parse(value!);
                getTransactionsForMonthAndYear();
              });
            },
            items: years
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      item.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: _deviceWidth! * 0.013,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            onPressed: () async {
              if (currentYear == 2030) {
                currentYear = years[0];
              } else {
                currentYear = currentYear + 1;
              }
              await getTransactionsForMonthAndYear();
              setState(() {});
            },
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.black,
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
      width: _deviceWidth! * 0.75,
      height: _deviceHeight! * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Vous n'avez pas encore de transaction pour le mois de ${MonthEnum().getStringFromId(currentMonthId)} $currentYear",
              style: const TextStyle(color: Colors.white, fontSize: 45),
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
      margin: const EdgeInsets.only(left: 40.0, top: 20.0),
      width: _deviceWidth! * 0.40,
      height: _deviceHeight! * 0.78,
      child: ListView.builder(
        itemCount: resultTransactions.length,
        itemBuilder: (BuildContext context, int index) {
          String? newDate = formatDate(resultTransactions[index]["date"]!);
          return ListTile(
            onTap: () {
              setState(() {
                selectedTileId = resultTransactions[index]["id"];
                description = resultTransactions[index]["description"]!;
                descriptionTxt.text = resultTransactions[index]["description"]!;
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
                    ? Colors.green
                    : Colors.red,
            leading: const Icon(Icons.list),
            title: Text(resultTransactions[index]["description"]!),
            subtitle: Text(newDate!),
            trailing: SizedBox(
              width: _deviceWidth! * 0.15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: _deviceWidth! * 0.03,
                    child: Text(
                      PaymentMethodEnum().getShortLabel(
                          resultTransactions[index]['paymentMethod']!),
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(
                    width: _deviceWidth! * 0.03,
                    child: Text(
                      resultTransactions[index]['amount']!,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(
                    width: _deviceHeight! * 0.03,
                  ),
                  SizedBox(
                    width: _deviceWidth! * 0.07,
                    child: Text(
                      resultTransactions[index]['catName']!,
                      style: const TextStyle(
                        fontSize: 14,
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
    );
  }

  Widget updateTransactionSectionWidget() {
    return Visibility(
      visible: selectedTileId == null ? false : true,
      child: Container(
        margin: const EdgeInsets.only(left: 20.0, top: 20.0),
        width: _deviceWidth! * 0.38,
        height: _deviceHeight! * 0.78,
        decoration: BoxDecoration(
            color: const Color.fromARGB(51, 94, 93, 93),
            borderRadius: BorderRadius.circular(40)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              selectTransactionWidget(0.01, 0.12),
              selectPaymentMethodWidget(0.008, 0.1),
              categorieSelectionWidget(),
              descriptionWidget(),
              montantWidget(),
              dateSelectionWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red.shade800,
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
                      )),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      backgroundColor: const Color.fromARGB(255, 29, 161, 242),
                    ),
                    child: Text(
                      'label_save_transaction'.i18n(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _deviceWidth! * 0.015,
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
                  _groupValue = value;
                });
              }),
        ),
      ),
    );
  }

  Widget generalCurrentInformations(String label, String value) {
    return SizedBox(
      width: _deviceWidth! *
          0.8 /
          4, // 2 est le nombre de homeCurrentInformations sur la même ligne
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
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

  double customTransactionInputWidth() {
    return _deviceWidth! * 0.3;
  }

  Widget selectTransactionWidget(double fontSize, double boxWidth) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        radioButtonLabelledTransactions(
            'label_depense'.i18n(),
            TransactionEnum.DEPENSE,
            _groupValueTransaction,
            fontSize,
            boxWidth,
            'transactionType'),
        SizedBox(
          width: _deviceWidth! * 0.05,
        ),
        radioButtonLabelledTransactions(
            'label_revenu'.i18n(),
            TransactionEnum.REVENU,
            _groupValueTransaction,
            fontSize,
            boxWidth,
            'transactionType'),
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
      width: customTransactionInputWidth(),
      child: TextFormField(
        controller: descriptionTxt,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'label_enter_desc'.i18n().toUpperCase(),
          labelStyle: TextStyle(
            color: Colors.white,
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
        controller: montantTxt,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'label_enter_amount'.i18n().toUpperCase(),
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: _deviceWidth! * 0.015,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: _deviceWidth! * 0.015,
        ),
        onChanged: ((value) {
          setState(() {
            double bmax = BigInt.parse("9223372036854775807") as double;
            double bmin = BigInt.parse("-9223372036854775807") as double;
            if (double.parse(value) >= bmax) {
              montant = bmax;
              showToast(context, Text("Max value is $bmax"));
            } else if (double.parse(value) <= bmin) {
              montant = bmin;
              showToast(context, Text("Min value is $bmin"));
            } else if (value.contains(",")) {
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
            width: _deviceWidth! * 0.025,
            height: _deviceHeight! * 0.01,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20.0),
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
                  color: Colors.white, fontSize: _deviceWidth! * 0.007),
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
        value: selectedItem!.id.toString(),
        onChanged: (value) {
          setState(() {
            selectedItem = findCategFromId(value!);
          });
        },
        items: dropDownItems!
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id.toString(),
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _deviceWidth! * 0.013,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
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
                'label_cbretrait'.i18n(),
                PaymentMethodEnum.CBRETRAIT,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            SizedBox(
              width: _deviceWidth! * 0.005,
            ),
            radioButtonLabelledTransactions(
                'label_cbcommerces'.i18n(),
                PaymentMethodEnum.CBCOMMERCES,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            SizedBox(
              width: _deviceWidth! * 0.005,
            ),
            radioButtonLabelledTransactions(
                'label_cheque'.i18n(),
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
                'label_virement'.i18n(),
                PaymentMethodEnum.VIREMENT,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            SizedBox(
              width: _deviceWidth! * 0.005,
            ),
            radioButtonLabelledTransactions(
                'label_prelevement'.i18n(),
                PaymentMethodEnum.PRELEVEMENT,
                _groupValuePaymentMethod,
                fontSize,
                boxWidth,
                'paymentMethod'),
            SizedBox(
              width: _deviceWidth! * 0.005,
            ),
            radioButtonLabelledTransactions(
                'label_paypal'.i18n(),
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
                  _groupValue = value;
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

  Future<void> _getMyInformations() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.get(Uri.parse("$serverUrl/getAmounts/$userId"));
    if (response.statusCode != 200) {
      throw Exception();
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
    var response =
        await http.post(Uri.parse("$serverUrl/deleteTransaction/$id"));
    if (response.statusCode != 204) {
      throw Exception();
    }
    await getTransactionsForMonthAndYear();
  }

  Future<void> updateTransaction(List<dynamic> params) async {
    var response = await http.post(
      Uri.parse(
          "$serverUrl/updateTransaction/${params[5]}?date=${params[0].year}-${params[0].month}-${params[0].day}&type=${params[1]}&amount=${params[2]}&description=${params[3]}&catId=${params[4]}&paymentMethod=${params[6]}"),
    );
    if (response.statusCode != 200) {
      throw Exception();
    }
  }

  Future<void> getTransactionsForMonthAndYear() async {
    resultTransactions = [];
    selectedTileId = null;
    String? userId = "1";
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
    var response = await http.get(Uri.parse(
        "$serverUrl/getTransactionsForMonthAndYear?userId=$userId&selectedMonthId=$currentMonthId&selectedYear=$currentYear"));
    return json.decode(response.body) != null
        ? (json.decode(response.body) as List)
            .map((e) => TransactionByMonthAndYear.fromJson(e))
            .toList()
        : [];
  }
}
