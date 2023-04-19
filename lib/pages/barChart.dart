import 'package:budgetly/pages/app_colors.dart';
import 'package:budgetly/pages/color_extensions.dart';
import 'package:budgetly/utils/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.totalDepense,
    required this.totalRevenu,
    required this.color,
    required this.deviceWidth,
  });
  final double totalDepense;
  final double totalRevenu;
  final String color;
  final double deviceWidth;

  @override
  Widget build(BuildContext context) {
    bool test = false;
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.center,
        groupsSpace: 70,
        maxY: max(totalDepense, totalRevenu),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            String color = "#dc6c68";
            if (groupIndex == 1) {
              color = "#133543";
            }
            return BarTooltipItem(
              "${rod.toY.toStringAsFixed(2)} €",
              TextStyle(
                color: color.toColor(),
                fontSize: deviceWidth * 0.012,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    String color = "";
    String text = "";
    switch (value.toInt()) {
      case 0:
        text = 'Depenses'.toUpperCase();
        color = "#dc6c68";
        break;
      case 1:
        text = 'Revenus'.toUpperCase();
        color = "#133543";
        break;
    }
    final style = TextStyle(
      color: color.toColor(),
      fontWeight: FontWeight.bold,
      fontSize: deviceWidth * 0.012,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          AppColors.contentColorBlue.darken(20),
          AppColors.contentColorCyan,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
                toY: totalDepense,
                color: "#dc6c68".toColor(),
                width: 75,
                borderRadius: BorderRadius.zero)
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
                toY: totalRevenu,
                color: "#133543".toColor(),
                width: 75,
                borderRadius: BorderRadius.zero)
          ],
          showingTooltipIndicators: [0],
        ),
      ];
}

class BarChartSample3 extends StatefulWidget {
  const BarChartSample3(
      {Key? key,
      required this.totalDepense,
      required this.totalRevenu,
      required this.deviceWidth})
      : super(key: key);

  final double totalDepense;
  final double totalRevenu;
  final double deviceWidth;

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  String color = "";
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.106,
      child: _BarChart(
        totalDepense: widget.totalDepense,
        totalRevenu: widget.totalRevenu,
        color: color,
        deviceWidth: widget.deviceWidth,
      ),
    );
  }
}
