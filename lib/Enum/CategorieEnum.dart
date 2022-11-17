// ignore_for_file: file_names, non_constant_identifier_names

class CategorieEnum {
  static String get LOISIRS => "Loisirs";
  static String get LOYER => "Loyer";
  static String get COURSES => "Courses";
  static String get PRET => "Prêt";
  static String get REMBOURSEMENT => "Remboursement";
  static String get SALAIRE => "Salaire";

  int getIdFromEnum(String? str) {
    switch (str) {
      case "Loisirs":
        return 1;
      case "Loyer":
        return 2;
      case "Courses":
        return 3;
      case "Prêt":
        return 4;
      case "Remboursement":
        return 5;
      case "Salaire":
        return 6;
      default:
        return 0;
    }
  }
}
