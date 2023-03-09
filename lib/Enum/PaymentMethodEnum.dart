// ignore_for_file: non_constant_identifier_names, file_names

import 'package:localization/localization.dart';

class PaymentMethodEnum {
  static String get CBRETRAIT => "CBRETRAIT";
  static String get CBCOMMERCES => "CBCOMMERCES";
  static String get CHEQUE => "CHEQUE";
  static String get VIREMENT => "VIREMENT";
  static String get PRELEVEMENT => "PRELEVEMENT";
  static String get PAYPAL => "PAYPAL";

  String getShortLabel(String str) {
    switch (str.toUpperCase()) {
      case "CBRETRAIT":
        return 'label_cbretrait_short'.i18n();
      case "CBCOMMERCES":
        return 'label_cbcommerces_short'.i18n();
      case "CHEQUE":
        return 'label_cheque_short'.i18n();
      case "VIREMENT":
        return 'label_virement_short'.i18n();
      case "PRELEVEMENT":
        return 'label_prelevement_short'.i18n();
      case "PAYPAL":
        return 'label_paypal_short'.i18n();
      default:
        "unknown";
    }
    return "";
  }
}
