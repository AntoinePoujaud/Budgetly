// ignore_for_file: file_names
import 'package:budgetly/Enum/FilterGeneralEnum.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:flutter/material.dart';
import 'mysql.dart';

class TableauGeneral extends StatefulWidget {
  const TableauGeneral({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  TableauGeneralState createState() => TableauGeneralState();
}

class TableauGeneralState extends State<TableauGeneral> {
  double? _deviceHeight, _deviceWidth;
  var db = Mysql();
  var currentAmount = '';
  var currentRealAmount = '';
  String? _groupValue = FilterGeneralEnum.LAST;

  @override
  void initState() {
    _getMyInformations();
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
              Container(
                margin: const EdgeInsets.only(left: 30.0),
                child: radioButtonLabelledFilter("LAST TRANSACTIONS",
                    FilterGeneralEnum.LAST, _groupValue, ""),
              ),
              Container(
                margin: const EdgeInsets.only(left: 30.0),
                color: Colors.blue,
                child: SizedBox(
                  width: _deviceWidth! * 0.82,
                  height: _deviceHeight! * 0.9,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          generalCurrentInformations(
                              'Montant actuel sur le compte', currentAmount),
                          generalCurrentInformations(
                              'Montant réel disponible', currentRealAmount),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
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
        currentAmount = row.assoc().values.first.toString();
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
        currentRealAmount = row.assoc().values.first.toString();
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
    return _deviceWidth! * 0.5;
  }
}
