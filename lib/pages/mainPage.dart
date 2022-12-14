// ignore_for_file: file_names
import 'package:budgetly/utils/menuLayout.dart';
import 'package:budgetly/widgets/NavDrawer.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../sql/mysql.dart';

class TableauRecap extends StatefulWidget {
  const TableauRecap({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  TableauRecapState createState() => TableauRecapState();
}

class TableauRecapState extends State<TableauRecap> {
  double? _deviceHeight, _deviceWidth;
  var db = Mysql();
  var currentAmount = '';
  var currentRealAmount = '';
  String currentPage = 'Tableau récapitulatif';

  Future<void> _getMyInformations() async {
    _getMyCurrentAmount();
    _getMyCurrentRealAmount();
  }

  Future<void> _getMyCurrentAmount() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    String query = 'SELECT current_amount FROM user where id = $userId;';
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
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    String query = 'SELECT current_real_amount FROM user where id = $userId;';
    var connection = await db.getConnection();
    var results = await connection.execute(query, {}, true);
    results.rowsStream.listen((row) {
      setState(() {
        currentRealAmount = row.assoc().values.first.toString();
      });
    });
    connection.close();
  }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              homeCurrentInformations('actual_amount'.i18n(), currentAmount),
              homeCurrentInformations('real_amount'.i18n(), currentRealAmount),
            ],
          ),
        ],
      ),
    );
  }

  Widget homeCurrentInformations(String label, String value) {
    return SizedBox(
      width: _deviceWidth! *
          0.85 /
          2, // 2 est le nombre de homeCurrentInformations sur la même ligne
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

  Widget mainMenu(String currentPage) {
    return Container(
      height: _deviceHeight! * 1,
      width: _deviceWidth! * 0.15,
      color: const Color.fromARGB(50, 225, 232, 237),
      child: NavDrawer(
        currentPage: currentPage,
      ),
    );
  }
}
