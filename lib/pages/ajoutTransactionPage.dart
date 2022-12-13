// ignore_for_file: file_names
import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enum/TransactionEnum.dart';
import '../sql/mysql.dart';

class AjoutTransaction extends StatefulWidget {
  const AjoutTransaction({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  AjoutTransactionState createState() => AjoutTransactionState();
}

class AjoutTransactionState extends State<AjoutTransaction> {
  double? _deviceHeight, _deviceWidth;
  var db = Mysql();
  String? _groupValue = TransactionEnum.NONE;
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  List<String>? dropDownItems = [];
  String? selectedItem;

  String? transactionType;
  double? montant;
  DateTime? currentDate;
  String? description;
  String? categorie = CategorieEnum.LOISIRS;

  double? actualUserAmount;

  @override
  void initState() {
    getActualRealAmount();
    super.initState();
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
                descriptionWidget(),
                montantWidget(),
                dateSelectionWidget(),
                categorieSelectionWidget(),
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
                        montant,
                        description,
                        CategorieEnum().getIdFromEnum(context, selectedItem),
                      ]);

                      await updateRealMontant(transactionType, montant);
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
        keyboardType: TextInputType.number,
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
            '${date.day}/${date.month}/${date.year}',
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

  Future<void> addTransaction(List<dynamic> params) async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    try {
      String query =
          "INSERT INTO transaction(date, type, montant, description, categorieID, userID) VALUES (?, ?, ?, ?, ?, $userId);";
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
      ]);

      await stmt.deallocate();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }

  Future<void> updateRealMontant(String? type, double? montant) async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    if (type == TransactionEnum.DEPENSE) {
      montant = (actualUserAmount! - montant!);
    } else if (type == TransactionEnum.REVENU) {
      montant = (montant! + actualUserAmount!);
    }
    String query =
        "UPDATE user SET current_real_amount = $montant WHERE id = $userId;";
    var connection = await db.getConnection();
    await connection.execute(query, {}, true);
    connection.close();
  }

  Future<void> getActualRealAmount() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    String query = "SELECT current_real_amount FROM user WHERE id = $userId;";
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      actualUserAmount = double.tryParse(row.assoc().values.first!);
    });
    connection.close();
  }

  void resetAllValues() {
    Navigator.popAndPushNamed(context, "/addTransaction");
  }
}
