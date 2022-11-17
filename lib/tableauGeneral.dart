// ignore_for_file: file_names
import 'package:budgetly/utils/menuLayout.dart';
import 'package:budgetly/widgets/NavDrawer.dart';
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
              homeCurrentInformations(
                  'Montant actuel sur le compte', currentAmount),
              homeCurrentInformations(
                  'Montant réel disponible', currentRealAmount),
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
      child: NavDrawer(currentPage: currentPage),
    );
  }
}
