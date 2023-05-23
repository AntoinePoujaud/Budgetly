import 'dart:math';

import 'package:budgetly/utils/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2(
      {Key? key,
      required this.data,
      required this.monthDays,
      required this.max,
      required this.min})
      : super(key: key);
  final List<FlSpot> data;
  final int monthDays;
  final int min;
  final int max;

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  double? _deviceWidth;
  bool isMobile = false;
  bool isDesktop = false;

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    isMobile = _deviceWidth! < 768;
    isDesktop = _deviceWidth! > 1024;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: isMobile ? 16 / 7 : 4,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  int calculateNumber(int number) {
    int a = number % 100;
    if (a > 0) {
      return (number.abs() ~/ 100) * 100 + 100;
    }
    return number;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (isMobile &&
        value != 1 &&
        value != 5 &&
        value != 10 &&
        value != 15 &&
        value != 20 &&
        value != 25 &&
        value != widget.monthDays) {
      return Text("");
    }
    TextStyle style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: isMobile ? 8 : 16,
    );
    Widget text = Text(
      value.toString(),
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: isMobile ? _deviceWidth! * 0.035 : _deviceWidth! * 0.01,
    );
    String text = value.toString();

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    int sideInterval =
        max(calculateNumber(widget.max), calculateNumber(widget.min));
    if (sideInterval != 0) {
      return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: "#CCE4DD".toColor(),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: "#CCE4DD".toColor(),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: sideInterval.toDouble(),
              getTitlesWidget: leftTitleWidgets,
              reservedSize: isMobile ? 40 : 62,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
              left: BorderSide(color: "#133543".toColor()),
              bottom: BorderSide(color: "#133543".toColor())),
        ),
        minX: 1,
        maxX: widget.monthDays.toDouble(),
        minY: sideInterval.toDouble() * -1,
        maxY: sideInterval.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: widget.data,
            isCurved: false,
            color: "#68b8b9".toColor(),
            barWidth: isMobile ? 4 : 10,
            isStrokeCapRound: false,
            isStrokeJoinRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: "#133543".toColor(),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: "#8d8d8d".toColor(),
            tooltipRoundedRadius: isMobile ? 5 : 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                TextStyle textStyle = TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      isMobile ? _deviceWidth! * 0.03 : _deviceWidth! * 0.01,
                );
                return LineTooltipItem(
                    '${touchedSpot.y.toString()} €', textStyle);
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((int index) {
              /// Indicator Line
              var lineColor = "#8d8d8d".toColor();
              const lineStrokeWidth = 4.0;
              final flLine =
                  FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

              var dotSize = 10.0;
              if (barData.dotData.show) {
                dotSize = 4.0 * 1.8;
              }

              final dotData = FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    _defaultGetDotPainter(spot, percent, bar, index,
                        size: dotSize),
              );

              return TouchedSpotIndicatorData(flLine, dotData);
            }).toList();
          },
        ),
      );
    }
    return LineChartData();
  }

  Color _defaultGetDotColor(
      FlSpot _, double xPercentage, LineChartBarData bar) {
    return "#8d8d8d".toColor();
  }

  FlDotPainter _defaultGetDotPainter(
    FlSpot spot,
    double xPercentage,
    LineChartBarData bar,
    int index, {
    double? size,
  }) {
    return FlDotCirclePainter(
      radius: size,
      color: _defaultGetDotColor(spot, xPercentage, bar),
      strokeColor: _defaultGetDotStrokeColor(spot, xPercentage, bar),
    );
  }

  Color _defaultGetDotStrokeColor(
    FlSpot spot,
    double xPercentage,
    LineChartBarData bar,
  ) {
    Color color;
    color = "#8d8d8d".toColor();
    return color;
  }
}
