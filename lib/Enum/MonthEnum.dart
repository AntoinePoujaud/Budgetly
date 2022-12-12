// ignore_for_file: file_names, non_constant_identifier_names

import 'package:localization/localization.dart';

class MonthEnum {
  static int get JANUARY => 1;
  static int get FEBRUARY => 2;
  static int get MARCH => 3;
  static int get APRIL => 4;
  static int get MAY => 5;
  static int get JUNE => 6;
  static int get JULY => 7;
  static int get AUGUST => 8;
  static int get SEPTEMBER => 9;
  static int get OCTOBER => 10;
  static int get NOVEMBER => 11;
  static int get DECEMBER => 12;

  String getStringFromId(int? id) {
    switch (id) {
      case 1:
        return 'label_month_january'.i18n();
      case 2:
        return 'label_month_february'.i18n();
      case 3:
        return 'label_month_march'.i18n();
      case 4:
        return 'label_month_april'.i18n();
      case 5:
        return 'label_month_may'.i18n();
      case 6:
        return 'label_month_june'.i18n();
      case 7:
        return 'label_month_july'.i18n();
      case 8:
        return 'label_month_august'.i18n();
      case 9:
        return 'label_month_september'.i18n();
      case 10:
        return 'label_month_october'.i18n();
      case 11:
        return 'label_month_november'.i18n();
      case 12:
        return 'label_month_december'.i18n();
      default:
        return "";
    }
  }

  int getIdFromString(String? month) {
    switch (month) {
      case "january":
        return 1;
      case "february":
        return 2;
      case "march":
        return 3;
      case "april":
        return 4;
      case "may":
        return 5;
      case "june":
        return 6;
      case "july":
        return 7;
      case "august":
        return 8;
      case "september":
        return 9;
      case "october":
        return 10;
      case "november":
        return 11;
      case "december":
        return 12;
      default:
        return 0;
    }
  }
}
