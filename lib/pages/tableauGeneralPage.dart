// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/Enum/FilterGeneralEnum.dart';
import 'package:budgetly/Enum/TransactionEnum.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enum/MonthEnum.dart';
import '../models/TransactionByMonthAndYear.dart';
import '../sql/mysql.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  double? _deviceHeight, _deviceWidth;
  var db = Mysql();
  double? currentAmount;
  double? currentRealAmount;
  String? _groupValue = FilterGeneralEnum.LAST;
  List<Map<String, String?>> resultTransactions = [];
  DateTime date = DateTime.now();
  List<String>? dropDownItems = [];
  final _formKey = GlobalKey<FormState>();

  String? selectedItem;
  String? description;
  String? transactionType;
  double? montant;
  DateTime? currentDate;
  String? _groupValueTransaction;
  String? selectedTileId;

  TextEditingController descriptionTxt = TextEditingController();
  TextEditingController montantTxt = TextEditingController();

  List<int>? months;
  int? currentMonthId;
  List<int>? years;
  int? currentYear;

  @override
  void initState() {
    getTransactionsForMonthAndYear();
    months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    currentMonthId = MonthEnum()
        .getIdFromString(DateFormat.MMMM("en").format(date).toLowerCase());
    years = [2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030];
    currentYear = date.year;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 23, 26),
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
            children: <Widget>[
              Visibility(
                visible: false, // on verra plus tard pour les filtres
                child: Container(
                  margin: const EdgeInsets.only(left: 30.0),
                  child: radioButtonLabelledFilter("LAST TRANSACTIONS",
                      FilterGeneralEnum.LAST, _groupValue, ""),
                ),
              ),
              SizedBox(
                width: _deviceWidth! * 0.82,
                height: _deviceHeight! * 0.9,
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        generalCurrentInformations(
                            'actual_amount'.i18n(), currentAmount.toString()),
                        generalCurrentInformations(
                            'real_amount'.i18n(), currentRealAmount.toString()),
                      ],
                    ),
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
      ),
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
                  currentYear = years![years!.length - 1];
                } else {
                  currentYear = currentYear! - 1;
                }
              } else {
                currentMonthId = currentMonthId! - 1;
              }
              await getTransactionsForMonthAndYear();
              setState(() {});
            },
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: const Color.fromARGB(255, 29, 161, 242),
            value: currentMonthId.toString(),
            onChanged: (value) {
              setState(() {
                currentMonthId = int.parse(value!);
                getTransactionsForMonthAndYear();
              });
            },
            items: months!
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      MonthEnum().getStringFromId(item),
                      style: TextStyle(
                        color: Colors.white,
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
                  currentYear = years![0];
                } else {
                  currentYear = currentYear! + 1;
                }
              } else {
                currentMonthId = currentMonthId! + 1;
              }
              await getTransactionsForMonthAndYear();
              setState(() {});
            },
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (currentYear == 2022) {
                currentYear = years![years!.length - 1];
              } else {
                currentYear = currentYear! - 1;
              }
              await getTransactionsForMonthAndYear();
              setState(() {});
            },
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: const Color.fromARGB(255, 29, 161, 242),
            value: currentYear.toString(),
            onChanged: (value) {
              setState(() {
                currentYear = int.parse(value!);
                getTransactionsForMonthAndYear();
              });
            },
            items: years!
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      item.toString(),
                      style: TextStyle(
                        color: Colors.white,
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
                currentYear = years![0];
              } else {
                currentYear = currentYear! + 1;
              }
              await getTransactionsForMonthAndYear();
              setState(() {});
            },
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
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
              "Vous n'avez pas encore de transaction pour le mois de ${MonthEnum().getStringFromId(currentMonthId)}",
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
                      Navigator.pushNamed(context, "/addTransaction");
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
                date = DateTime.parse(resultTransactions[index]["date"]!);
                selectedItem = CategorieEnum().getStringFromId(
                    int.parse(resultTransactions[index]["catId"]!));
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
              width: _deviceWidth! * 0.12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                      CategorieEnum().getStringFromId(
                          int.parse(resultTransactions[index]['catId']!)),
                      style: const TextStyle(
                        fontSize: 18,
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
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(40)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              selectTransactionWidget(),
              descriptionWidget(),
              montantWidget(),
              dateSelectionWidget(),
              categorieSelectionWidget(),
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
                          CategorieEnum().getIdFromEnum(context, selectedItem),
                          selectedTileId
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
          style: customTextStyle(),
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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle customTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 18,
    );
  }

  double customTransactionInputWidth() {
    return _deviceWidth! * 0.3;
  }

  Widget selectTransactionWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        radioButtonLabelledTransactions('label_depense'.i18n(),
            TransactionEnum.DEPENSE, _groupValueTransaction),
        SizedBox(
          width: _deviceWidth! * 0.05,
        ),
        radioButtonLabelledTransactions('label_revenu'.i18n(),
            TransactionEnum.REVENU, _groupValueTransaction),
      ],
    );
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
            '${date.day}/${date.month}/${date.year}',
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
        dropdownColor: const Color.fromARGB(255, 29, 161, 242),
        value: selectedItem,
        onChanged: (value) {
          setState(() {
            List<String>? temp = [];
            selectedItem = value.toString();
            dropDownItems!.removeWhere((element) => element == selectedItem);
            temp.add(selectedItem!);
            //Sort List alphabetically
            dropDownItems!.sort((a, b) {
              return a[0].toLowerCase().compareTo(b[0].toLowerCase());
            });
            temp.addAll(dropDownItems!);
            dropDownItems = temp;
          });
        },
        items: dropDownItems!
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
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
                _groupValueTransaction = value;
                transactionType = value;
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
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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

  Future<List<String>> getAllCategories() async {
    List<String> allCategories = [];
    var response =
        await http.get(Uri.parse("http://localhost:8081/getCategories"));
    if (json.decode(response.body) != null) {
      for (var i = 0; i < json.decode(response.body).length; i++) {
        allCategories.add(json.decode(response.body)[i]["name"]);
      }
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
    var response =
        await http.get(Uri.parse("http://localhost:8081/getAmounts/$userId"));
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
    var response = await http
        .delete(Uri.parse("http://localhost:8081/deleteTransaction/$id"));
    if (response.statusCode != 204) {
      throw Exception();
    }
    await getTransactionsForMonthAndYear();
  }

  Future<void> updateTransaction(List<dynamic> params) async {
    var response = await http.put(
      Uri.parse(
          "http://localhost:8081/updateTransaction/${params[5]}?date=${params[0].year}-${params[0].month}-${params[0].day}&type=${params[1]}&amount=${params[2]}&description=${params[3]}&catId=${params[4]}"),
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
    var fetchedTransactions = await fetchTransactions(userId);
    if (fetchedTransactions.isNotEmpty) {
      setState(() {
        for (var transaction in fetchedTransactions) {
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
        "http://localhost:8081/getTransactionsForMonthAndYear?userId=$userId&selectedMonthId=$currentMonthId&selectedYear=$currentYear"));
    return json.decode(response.body) != null
        ? (json.decode(response.body) as List)
            .map((e) => TransactionByMonthAndYear.fromJson(e))
            .toList()
        : [];
  }
}
