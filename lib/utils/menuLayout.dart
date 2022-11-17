// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../widgets/NavDrawer.dart';

class MenuLayout extends StatelessWidget {
  const MenuLayout(
      {Key? key,
      required this.title,
      required this.deviceHeight,
      required this.deviceWidth})
      : super(key: key);
  final String title;
  final double? deviceHeight, deviceWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: deviceHeight! * 1,
      width: deviceWidth! * 0.15,
      color: const Color.fromARGB(50, 225, 232, 237),
      child: NavDrawer(currentPage: title),
    );
  }
}
