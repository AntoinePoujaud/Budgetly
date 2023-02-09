import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Future<bool> checkIfConnected(context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") == null) {
      // ignore: use_build_context_synchronously
      Navigator.popAndPushNamed(context, "/login");
      return false;
    }
    return true;
  }
}
