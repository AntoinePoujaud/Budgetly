// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:localization/localization.dart';

class CategorieEnum {
  static String get LOISIRS => "LOISIRS";
  static String get LOYER => "LOYER";
  static String get COURSES => "Courses";
  static String get PRET => "Prêt";
  static String get REMBOURSEMENT => "Remboursement";
  static String get SALAIRE => "Salaire";

  int getIdFromEnum(BuildContext context, String str) {
    str = str.toLowerCase();
    switch (str) {
      case "loisirs":
        return 1;
      case "loyer":
        return 2;
      case "courses":
        return 3;
      case "prêt":
        return 4;
      case "remboursement":
        return 5;
      case "salaire":
        return 6;
      default:
        return 0;
    }
  }

  String getStringFromId(int? id) {
    switch (id) {
      case 1:
        return 'enum_categorie_hobby'.i18n();
      case 2:
        return 'enum_categorie_rent'.i18n();
      case 3:
        return 'enum_categorie_shopping'.i18n();
      case 4:
        return 'enum_categorie_loan'.i18n();
      case 5:
        return 'enum_categorie_refund'.i18n();
      case 6:
        return 'enum_categorie_salary'.i18n();
      default:
        return "";
    }
  }
  
}
