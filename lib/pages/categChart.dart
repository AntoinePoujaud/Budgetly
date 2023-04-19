import 'package:budgetly/utils/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budgetly/pages/app_colors.dart';

class PieChartSample3 extends StatefulWidget {
  const PieChartSample3({
    Key? key,
    required this.percentages,
    required this.names,
    required this.totals,
    required this.colors,
  }) : super(key: key);
  final List<dynamic> percentages;
  final List<dynamic> totals;
  final List<dynamic> names;
  final List<String> colors;

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State<PieChartSample3> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 1,
            centerSpaceRadius: 0,
            sections: showingSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if (widget.totals.isNotEmpty) {
      return List.generate(widget.totals.length, (i) {
        String color = "";
        final isTouched = i == touchedIndex;
        double fontSize = isTouched ? 24.0 : 20.0;
        if (widget.percentages[i] <= 5) {
          fontSize = isTouched ? 14.0 : 10.0;
        }
        final radius = isTouched ? 205.0 : 195.0;
        final widgetSize = isTouched ? 155.0 : 140.0;
        final text =
            isTouched ? "${widget.totals[i]} €" : "${widget.percentages[i]} %";
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        if (widget.colors.asMap().containsKey(i)) {
          color = widget.colors[i];
        } else {
          if (i - widget.colors.length >= widget.colors.length) {
            color = widget.colors[widget.colors.length - 1];
          } else {
            color = widget.colors[i - widget.colors.length];
          }
        }

        return PieChartSectionData(
          color: color.toColor(),
          value: widget.totals[i],
          title: text,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            // shadows: shadows,
          ),
          // badgeWidget: _Badge(
          //   'assets/icons/ophthalmology-svgrepo-com.svg',
          //   size: widgetSize,
          //   borderColor: AppColors.contentColorBlack,
          // text: widget.names[i],
          // ),
          // badgePositionPercentageOffset: .78,
          titlePositionPercentageOffset: .60,
        );
      });
    } else {
      return [
        PieChartSectionData(
          color: AppColors.contentColorBlue,
          value: 100,
          title: "Pas de données disponibles ce mois",
          titleStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titlePositionPercentageOffset: .30,
        ),
      ];
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.svgAsset,
      {required this.size, required this.borderColor, required this.text});
  final String svgAsset;
  final double size;
  final Color borderColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
