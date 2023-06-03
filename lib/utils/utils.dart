import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class Utils {
  static Future<bool> checkIfConnected(context) async {
    String serverUrl = 'https://moneytly.herokuapp.com';

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    String token = getCookieValue("token");
    if (prefs.getString("userId") == null || token == "") {
      Navigator.of(context)
        ..pop()
        ..pushNamed("/login");
      return false;
    }
    if (userId != "" && token != "") {
      var response = await http.get(
        Uri.parse("$serverUrl/checkUser/$userId"),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        Navigator.of(context)
          ..pop()
          ..pushNamed("/login");
        return false;
      }
    }
    return true;
  }

  static String getCookieValue(String name) {
    List<String> cookies = [];
    if (html.window.document.cookie == null) {
      return "";
    }

    cookies = html.window.document.cookie!.split(';');
    for (final cookie in cookies) {
      final parts = cookie.split('=');
      final cookieName = parts[0].trim();

      if (cookieName == name) {
        return parts[1].trim();
      }
    }
    return "";
  }
}
