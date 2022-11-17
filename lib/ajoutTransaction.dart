// ignore_for_file: file_names
import 'package:budgetly/Enum/CategorieEnum.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'Enum/TransactionEnum.dart';
import 'Enum/CategorieEnum.dart';
import 'mysql.dart';

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
  String? categorie;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

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
                  child: const Text(
                    "Enregistrer transaction",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  onPressed: () => {
                    addTransaction([
                      currentDate,
                      transactionType,
                      montant,
                      description,
                      CategorieEnum().GetIdFromEnum(selectedItem),
                    ])
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        radioButtonLabelledTransactions(
            "Dépense", TransactionEnum.DEPENSE, _groupValue, "end"),
        radioButtonLabelledTransactions(
            "Revenu", TransactionEnum.REVENU, _groupValue, ""),
      ],
    );
  }

  Widget descriptionWidget() {
    return SizedBox(
      width: customTransactionInputWidth(),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: "Entrer une Description".toUpperCase(),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
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
          labelText: "Entrer un Montant".toUpperCase(),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
        onChanged: ((value) {
          setState(() {
            montant = double.parse(value);
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          SizedBox(
            width: _deviceWidth! * 0.05,
            height: _deviceHeight! * 0.05,
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
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );

              if (newDate == null) return;
              setState(() {
                date = newDate;
                currentDate = newDate;
              });
            },
            child: const Text(
              "Sélectionner la date d'apparition de la transaction",
              style: TextStyle(color: Colors.white, fontSize: 16),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
    String align,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _deviceWidth! * 0.1,
        maxHeight: _deviceHeight! * 0.8,
      ),
      child: ListTile(
        title: Text(
          title,
          style: customTextStyle(),
          textAlign: align == "end" ? TextAlign.end : TextAlign.start,
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
    return const TextStyle(
      color: Colors.white,
      fontSize: 24,
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
    String query =
        "INSERT INTO transaction(date, type, montant, description, categorieID) VALUES (?, ?, ?, ?, ?)";
    var connection = await db.getConnection();
    var stmt = await connection.prepare(
      query,
    );
    await stmt.execute([
      "${params[0].year}-${params[0].month}-${params[0].day}",
      params[1],
      params[2],
      params[3],
      params[4]
    ]);
    await stmt.deallocate();
  }
}
