// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/pages/chartTest.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Enum/MonthEnum.dart';
import '../utils/utils.dart';
import 'barChart.dart';
import 'categChart.dart';

class TableauRecap extends StatefulWidget {
  const TableauRecap({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  TableauRecapState createState() => TableauRecapState();
}

class TableauRecapState extends State<TableauRecap> {
  int maxValue = 0;
  int minValue = 0;
  double totalDepense = 0;
  double totalRevenu = 0;
  double? _deviceHeight, _deviceWidth;
  double currentAmount = 0;
  double currentRealAmount = 0;
  List<dynamic> dailyStatsValues = [];
  List<dynamic> categStatsPercentages = [];
  List<dynamic> categStatsNames = [];
  List<dynamic> categStatsTotals = [];
  String currentPage = 'Tableau récapitulatif';
  List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  DateTime now = DateTime.now();
  List<FlSpot> dailySpots = [];
  int currentMonthId = MonthEnum().getIdFromString(
      DateFormat.MMMM("en").format(DateTime.now()).toLowerCase());
  List<int> years = [];
  int currentYear = DateTime.now().year;
  int? initialYear;
  int? initialMonth;
  List<String> filterMonthYears = [];
  // String serverUrl = 'https://moneytly.herokuapp.com';
  String serverUrl = 'http://localhost:8081';

  Future<void> _getMyInformations() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.get(Uri.parse("$serverUrl/getAmounts/$userId"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Can't fetch your informations"));
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

  Future<void> getDailyStats() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.get(Uri.parse(
        "$serverUrl/stats/$userId/daily?date=$currentYear-${currentMonthId < 10 ? '0$currentMonthId' : currentMonthId}-01"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Can't fetch your daily stats"));
    } else {
      setState(() {
        dailyStatsValues = json.decode(response.body)["amounts"].toList();
        maxValue = json.decode(response.body)["max"];
        minValue = json.decode(response.body)["min"];
        dailySpots = List.generate(
            DateUtils.getDaysInMonth(currentYear, currentMonthId), (index) {
          return FlSpot(index.toDouble() + 1, dailyStatsValues[index]);
        });
      });
    }
  }

  Future<void> getCategStats() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.get(Uri.parse(
        "$serverUrl/stats/$userId/categ?date=$currentYear-${currentMonthId < 10 ? '0$currentMonthId' : currentMonthId}-01"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Can't fetch your categ stats"));
    } else {
      if (json.decode(response.body)["isEmpty"] == false) {
        setState(() {
          categStatsTotals = json.decode(response.body)["totals"].toList();
          categStatsPercentages =
              json.decode(response.body)["percentages"].toList();
          categStatsNames = json.decode(response.body)["names"].toList();
        });
      } else {
        setState(() {
          categStatsTotals = [];
          categStatsPercentages = [];
          categStatsNames = [];
        });
      }
    }
  }

  Future<void> getTotalStats() async {
    String? userId = "1";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      userId = prefs.getString("userId");
    }
    var response = await http.get(Uri.parse(
        "$serverUrl/stats/$userId/total?date=$currentYear-${currentMonthId < 10 ? '0$currentMonthId' : currentMonthId}-01"));
    if (response.statusCode != 200) {
      // ignore: use_build_context_synchronously
      showToast(context, const Text("Can't fetch your total stats"));
    } else {
      setState(() {
        totalDepense = json.decode(response.body)["totalDepense"];
        totalRevenu = json.decode(response.body)["totalRevenu"];
      });
    }
  }

  Future<void> _getStats() async {
    getDailyStats();
    getCategStats();
    getTotalStats();
  }

  @override
  void initState() {
    super.initState();
    Utils.checkIfConnected(context).then((value) {
      if (value) {
        _getMyInformations();
        _getStats();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

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
                    SizedBox(
                        width: _deviceWidth! * 0.62,
                        height: _deviceHeight! * 0.3,
                        child: LineChartSample2(
                          data: dailySpots,
                          monthDays: DateUtils.getDaysInMonth(currentYear, currentMonthId),
                          min: minValue,
                          max: maxValue,
                        )),
                    SizedBox(
                      height: _deviceHeight! * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: _deviceWidth! * 0.4,
                          height: _deviceHeight! * 0.4,
                          child: PieChartSample3(
                            names: categStatsNames,
                            percentages: categStatsPercentages,
                            totals: categStatsTotals,
                          ),
                        ),
                        SizedBox(
                          height: _deviceHeight! * 0.4,
                          width: _deviceWidth! * 0.3,
                          child: BarChartSample3(
                              totalDepense: totalDepense,
                              totalRevenu: totalRevenu),
                        ),
                      ],
                    ),
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
                setState(() {
                  _getStats();
                });
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
                _getStats();
              });
            },
            items: filterMonthYears
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      "${MonthEnum().getStringFromId(int.parse(item.split(" ")[0]))} ${int.parse(item.split(" ")[1])}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: _deviceWidth! * 0.013,
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
                setState(() {
                  _getStats();
                });
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

  void showToast(BuildContext context, content) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: content));
  }
}
