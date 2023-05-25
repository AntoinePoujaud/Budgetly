// ignore_for_file: file_names
import 'dart:convert';

import 'package:budgetly/pages/chartTest.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:budgetly/utils/menuLayout.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<String> colors = [
    "#466563",
    "#ffffff",
    "#15646f",
    "#8d8d8d",
    "#184449",
    "#68b8b9",
    "#d0ad3b",
    "#dc6c68",
    "#133543",
    "#badf79",
  ];
  bool isMobile = false;
  bool isDesktop = false;
  String serverUrl = 'https://moneytly.herokuapp.com';
  // String serverUrl = 'http://localhost:8081';

  Future<void> _getMyInformations() async {
    String? userId = "";
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
    String? userId = "";
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
          return FlSpot(index.toDouble() + 1,
              double.parse(dailyStatsValues[index].toStringAsFixed(2)));
        });
      });
    }
  }

  Future<void> getCategStats() async {
    String? userId = "";
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
    String? userId = "";
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
    isMobile = _deviceWidth! < 768;
    if (_deviceWidth! > _deviceHeight!) {}
    isDesktop = _deviceWidth! > 1024;

    return Scaffold(
      backgroundColor: "#CCE4DD".toColor(),
      body: isMobile ? mobileWidget() : desktopWidget(),
    );
  }

  Widget desktopWidget() {
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
          children: [
            Container(
              color: "#0A454A".toColor(),
              width: _deviceWidth! * 0.85,
              height: _deviceHeight! * 0.1,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 0,
                    width: 0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      homeCurrentInformations(
                          isMobile
                              ? "Compte :".toUpperCase()
                              : 'actual_amount'.i18n().toUpperCase(),
                          currentAmount.toStringAsFixed(2)),
                      homeCurrentInformations(
                          isMobile
                              ? "Réel :".toUpperCase()
                              : 'real_amount'.i18n().toUpperCase(),
                          currentRealAmount.toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: _deviceWidth! * 0.82,
              height: _deviceHeight! * 0.9,
              child: Column(
                mainAxisAlignment: isMobile
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  selectMonthYearWidget(),
                  SizedBox(
                    width: _deviceWidth! * 0.72,
                    height: _deviceHeight! * 0.25,
                    child: LineChartSample2(
                      data: dailySpots,
                      monthDays:
                          DateUtils.getDaysInMonth(currentYear, currentMonthId),
                      min: minValue,
                      max: maxValue,
                    ),
                  ),
                  desktopStats(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget mobileWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            color: "#0A454A".toColor(),
            width: _deviceWidth!,
            height: _deviceHeight! * 0.1,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                mobileMenu(),
                const SizedBox(
                  width: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    homeCurrentInformations(
                        isMobile
                            ? "Compte :".toUpperCase()
                            : 'actual_amount'.i18n().toUpperCase(),
                        currentAmount.toStringAsFixed(2)),
                    homeCurrentInformations(
                        isMobile
                            ? "Réel :".toUpperCase()
                            : 'real_amount'.i18n().toUpperCase(),
                        currentRealAmount.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: _deviceWidth!,
            height: _deviceHeight! * 0.9,
            child: ListView(
              children: [
                selectMonthYearWidget(),
                SizedBox(
                  width: _deviceWidth!,
                  height: _deviceHeight! * 0.25,
                  child: LineChartSample2(
                    data: dailySpots,
                    monthDays:
                        DateUtils.getDaysInMonth(currentYear, currentMonthId),
                    min: minValue,
                    max: maxValue,
                  ),
                ),
                SizedBox(
                  width: _deviceWidth!,
                  height: _deviceHeight! * 0.5,
                  child: PieChartSample3(
                    names: categStatsNames,
                    percentages: categStatsPercentages,
                    totals: categStatsTotals,
                    colors: colors,
                  ),
                ),
                SizedBox(
                  width: _deviceWidth!,
                  height: _deviceHeight! * 0.12,
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 10,
                    runSpacing: 15,
                    runAlignment: WrapAlignment.center,
                    children: List.generate(categStatsNames.length, (index) {
                      String color = "";

                      if (colors.asMap().containsKey(index)) {
                        color = colors[index];
                      } else {
                        if (index - colors.length >= colors.length) {
                          color = colors[colors.length - 1];
                        } else {
                          color = colors[index - colors.length];
                        }
                      }
                      return categLegend(color, categStatsNames[index]);
                    }),
                  ),
                ),
                SizedBox(
                  width: _deviceWidth!,
                  height: _deviceHeight! * 0.1,
                ),
                SizedBox(
                  width: _deviceWidth!,
                  height: _deviceHeight! * 0.5,
                  child: BarChartSample3(
                    totalDepense: totalDepense,
                    totalRevenu: totalRevenu,
                    deviceWidth: _deviceWidth!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _deviceWidth! * 0.4,
              height: _deviceHeight! * 0.45,
              child: PieChartSample3(
                names: categStatsNames,
                percentages: categStatsPercentages,
                totals: categStatsTotals,
                colors: colors,
              ),
            ),
            SizedBox(
              width: _deviceWidth! * 0.4,
              height: _deviceHeight! * 0.1,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 20,
                runSpacing: 20,
                runAlignment: WrapAlignment.center,
                children: List.generate(categStatsNames.length, (index) {
                  String color = "";

                  if (colors.asMap().containsKey(index)) {
                    color = colors[index];
                  } else {
                    if (index - colors.length >= colors.length) {
                      color = colors[colors.length - 1];
                    } else {
                      color = colors[index - colors.length];
                    }
                  }
                  return categLegend(color, categStatsNames[index]);
                }),
              ),
            ),
          ],
        ),
        SizedBox(
          height: _deviceHeight! * 0.45,
          width: _deviceWidth! * 0.2,
          child: BarChartSample3(
            totalDepense: totalDepense,
            totalRevenu: totalRevenu,
            deviceWidth: _deviceWidth!,
          ),
        ),
      ],
    );
  }

  Widget mobileMenu() {
    return PopupMenuButton(
      color: "#133543".toColor(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(children: [
            Icon(
              Icons.home,
              color: widget.title == 'tableau_recap_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'tableau_recap_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'tableau_recap_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/");
            widget.title != 'tableau_recap_title'.i18n()
                ? Navigator.of(context).pushNamed("/")
                : "";
          },
        ),
        PopupMenuItem(
          value: 1,
          child: Row(children: [
            Icon(
              Icons.add,
              color: widget.title == 'add_transaction_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'add_transaction_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'add_transaction_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/addTransaction");
            widget.title != 'add_transaction_title'.i18n()
                ? Navigator.of(context).pushNamed("/addTransaction")
                : "";
          },
        ),
        PopupMenuItem(
          value: 2,
          child: Row(children: [
            Icon(
              Icons.manage_search,
              color: widget.title == 'tableau_general_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'tableau_general_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'tableau_general_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/transactions");
            widget.title != 'tableau_general_title'.i18n()
                ? Navigator.of(context).pushNamed("/transactions")
                : "";
          },
        ),
        PopupMenuItem(
          value: 3,
          child: Row(children: [
            Icon(
              Icons.settings,
              color: widget.title == 'settings_title'.i18n()
                  ? Colors.grey
                  : Colors.white,
            ),
            Text(
              'settings_title'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: widget.title == 'settings_title'.i18n()
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed("/settings");
            widget.title != 'settings_title'.i18n()
                ? Navigator.of(context).pushNamed("/settings")
                : "";
          },
        ),
        PopupMenuItem(
          value: 4,
          child: Row(children: [
            const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            Text(
              'label_disconnect'.i18n().toUpperCase(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ]),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("userId", "");
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamed("/login");
          },
        ),
      ],
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
      ),
    );
  }

  Widget categLegend(String boxColor, String categName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.square,
          size: isMobile ? 20 : 22,
          color: boxColor.toColor(),
        ),
        Text(
          categName,
          style: TextStyle(
              color: "#133543".toColor(), fontSize: isMobile ? 10 : 20),
        ),
      ],
    );
  }

  Widget selectMonthYearWidget() {
    return SizedBox(
      width: _deviceWidth! * 0.79,
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
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
                      "${MonthEnum().getStringFromId(int.parse(item.split(" ")[0]))} ${int.parse(item.split(" ")[1])}"
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isMobile
                            ? _deviceWidth! * 0.05
                            : _deviceWidth! * 0.013,
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
      width: isMobile
          ? _deviceWidth! / 3
          : _deviceWidth! *
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
            style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? _deviceWidth! * 0.04 : 32),
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
