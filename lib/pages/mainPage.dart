// ignore_for_file: file_names
import 'dart:convert';
import 'dart:math';

import 'package:budgetly/pages/test.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:budgetly/widgets/NavDrawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Enum/MonthEnum.dart';
import '../utils/utils.dart';

class TableauRecap extends StatefulWidget {
  const TableauRecap({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  TableauRecapState createState() => TableauRecapState();
}

class TableauRecapState extends State<TableauRecap> {
  double? _deviceHeight, _deviceWidth;
  double currentAmount = 0;
  double currentRealAmount = 0;
  String currentPage = 'Tableau récapitulatif';
  List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  int currentMonthId = MonthEnum().getIdFromString(
      DateFormat.MMMM("en").format(DateTime.now()).toLowerCase());
  List<int> years = [2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030];
  int currentYear = DateTime.now().year;
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';

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

  @override
  void initState() {
    super.initState();
    Utils.checkIfConnected(context).then((value) {
      if (value) {
        _getMyInformations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    final List<FlSpot> dummyData1 = List.generate(8, (index) {
      return FlSpot(index.toDouble(), index * Random().nextDouble());
    });
    print(dummyData1);

    return Scaffold(
      backgroundColor: "#CCE4DD".toColor(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuLayout(
              title: widget.title,
              deviceWidth: _deviceWidth,
              deviceHeight: _deviceHeight),
          Column(
            children: [
              Container(
                color: "#0A454A".toColor(),
                height: _deviceHeight! * 0.1,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    homeCurrentInformations('actual_amount'.i18n(),
                        currentAmount.toStringAsFixed(2)),
                    homeCurrentInformations('real_amount'.i18n(),
                        currentRealAmount.toStringAsFixed(2)),
                  ],
                ),
              ),
              SizedBox(
                width: _deviceWidth! * 0.82,
                height: _deviceHeight! * 0.9,
                child: Column(
                  children: [
                    selectMonthYearWidget(),
                    // resultTransactions.isNotEmpty
                    //     ? transactionsNotNullWidget()
                    //     : noTransactionWidget();
                    SizedBox(
                        width: _deviceWidth! * 0.62,
                        height: _deviceHeight! * 0.3,
                        child: LineChartSample3())
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
                  currentYear = years[years.length - 1];
                } else {
                  currentYear = currentYear - 1;
                }
              } else {
                currentMonthId = currentMonthId - 1;
              }
              // await getTransactionsForMonthAndYear();
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
                // getTransactionsForMonthAndYear();
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
              // await getTransactionsForMonthAndYear();
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
              // await getTransactionsForMonthAndYear();
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
                // getTransactionsForMonthAndYear();
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
              // await getTransactionsForMonthAndYear();
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

  Widget homeCurrentInformations(String label, String value) {
    return SizedBox(
      width: _deviceWidth! *
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
