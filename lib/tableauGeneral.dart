// ignore_for_file: file_names
import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/Enum/FilterGeneralEnum.dart';
import 'package:budgetly/Enum/TransactionEnum.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'mysql.dart';
import 'package:intl/intl.dart';

class TableauGeneral extends StatefulWidget {
  const TableauGeneral({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  TableauGeneralState createState() => TableauGeneralState();
}

class TableauGeneralState extends State<TableauGeneral> {
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

  @override
  void initState() {
    _getMyInformations();
    getTransactionsForMonth();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 40.0, top: 20.0),
                          width: _deviceWidth! * 0.40,
                          height: _deviceHeight! * 0.8,
                          child: ListView.builder(
                            itemCount: resultTransactions.length,
                            itemBuilder: (BuildContext context, int index) {
                              String? newDate = formatDate(
                                  resultTransactions[index]["date"]!);
                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    selectedTileId =
                                        resultTransactions[index]["id"];
                                    description = resultTransactions[index]
                                        ["description"]!;
                                    descriptionTxt.text =
                                        resultTransactions[index]
                                            ["description"]!;
                                    montant = double.parse(
                                        resultTransactions[index]["montant"]!);
                                    montantTxt.text =
                                        resultTransactions[index]["montant"]!;
                                    transactionType =
                                        resultTransactions[index]["type"];
                                    _groupValueTransaction =
                                        resultTransactions[index]["type"];
                                    date = DateTime.parse(
                                        resultTransactions[index]["date"]!);
                                    selectedItem = CategorieEnum()
                                        .getStringFromId(int.parse(
                                            resultTransactions[index]
                                                ["categorieID"]!));
                                  });
                                },
                                tileColor: resultTransactions[index]["type"] ==
                                        TransactionEnum.REVENU
                                    ? Colors.green
                                    : Colors.red,
                                leading: const Icon(Icons.list),
                                title: Text(
                                    resultTransactions[index]["description"]!),
                                subtitle: Text(newDate!),
                                trailing: SizedBox(
                                  width: _deviceWidth! * 0.12,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: _deviceWidth! * 0.03,
                                        child: Text(
                                          resultTransactions[index]['montant']!,
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
                                              int.parse(
                                                  resultTransactions[index]
                                                      ['categorieID']!)),
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
                        ),
                        showForm()
                      ],
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

  Widget pageWidget() {
    return Visibility(
      visible: selectedTileId == null ? false : true,
      child: Container(
        margin: const EdgeInsets.only(left: 20.0, top: 20.0),
        width: _deviceWidth! * 0.38,
        height: _deviceHeight! * 0.8,
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
                    await updateRealMontant(
                        transactionType, montant, selectedTileId);
                    await updateTransaction([
                      date,
                      transactionType,
                      montant,
                      description,
                      // ignore: use_build_context_synchronously
                      CategorieEnum().getIdFromEnum(context, selectedItem),
                      selectedTileId
                    ]);
                    resultTransactions = [];
                    await getTransactionsForMonth();
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
          ),
        ),
      ),
    );
  }

  Future<void> updateRealMontant(
      String? type, double? montant, String? id) async {
    await removeOldMontant(id);
    await addNewMontant(type, montant);
  }

  Future<void> addNewMontant(String? type, double? montant) async {
    if (type == TransactionEnum.DEPENSE) {
      montant =
          double.parse((currentRealAmount! - montant!).toStringAsFixed(2));
      currentRealAmount = montant;
    } else if (type == TransactionEnum.REVENU) {
      montant =
          double.parse((montant! + currentRealAmount!).toStringAsFixed(2));
      currentRealAmount = montant;
    }
    String query =
        "UPDATE user SET current_real_amount = $montant WHERE id = 1;";
    var connection = await db.getConnection();
    await connection.execute(query, {}, true);
    await connection.close();
  }

  Future<void> removeOldMontant(String? id) async {
    double? oldMontant;
    String? oldType;
    String query = "SELECT montant, type FROM transaction WHERE id = $id;";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      oldMontant = double.parse(row.assoc().values.first!);
      oldType = row.assoc().values.last;
      // setState(() {
      if (oldType == TransactionEnum.DEPENSE) {
        currentRealAmount =
            double.parse((currentRealAmount! + oldMontant!).toStringAsFixed(2));
      } else if (oldType == TransactionEnum.REVENU) {
        currentRealAmount =
            double.parse((currentRealAmount! - oldMontant!).toStringAsFixed(2));
      }
      // });
    });
    await connection.close();
  }

  Future<void> updateTransaction(List<dynamic> params) async {
    try {
      String query =
          "UPDATE transaction set date = ?, type = ?, montant = ?, description = ?, categorieID = ? WHERE id = ?;";
      var connection = await db.getConnection();

      var stmt = await connection.prepare(
        query,
      );
      await stmt.execute([
        "${params[0].year}-${params[0].month}-${params[0].day}",
        params[1],
        params[2],
        params[3],
        params[4],
        params[5]
      ]);

      await stmt.deallocate();
    } catch (e) {
      throw Exception();
    }
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

  Future<void> _getMyInformations() async {
    _getMyCurrentAmount();
    _getMyCurrentRealAmount();
  }

  Future<void> _getMyCurrentAmount() async {
    String query = 'SELECT current_amount FROM user where id = 1;';
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      setState(() {
        currentAmount = double.parse(row.assoc().values.first!);
      });
    });
    connection.close();
  }

  Future<void> _getMyCurrentRealAmount() async {
    String query = 'SELECT current_real_amount FROM user where id = 1;';
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      setState(() {
        currentRealAmount = double.parse(row.assoc().values.first!);
      });
    });
    connection.close();
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

  Future<void> getTransactionsForMonth() async {
    String query =
        "SELECT id, date, type, montant, description, categorieID FROM transaction where MONTH(date) >= MONTH(NOW()) ORDER BY DAY(date);";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      setState(() {
        resultTransactions.add(row.assoc());
      });
    });
    connection.close();
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
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
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

  Future<List<String>> getAllCategories() async {
    List<String> allCategories = [];
    String query = "SELECT nom FROM categorie;";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      allCategories.add(row.assoc().values.first.toString());
    });
    connection.close();
    return allCategories;
  }

  Widget showForm() {
    if (dropDownItems!.isEmpty) {
      return FutureBuilder(
        future: getAllCategories(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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
}
