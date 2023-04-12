// ignore_for_file: file_names
import 'package:budgetly/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key, required this.currentPage}) : super(key: key);
  final String currentPage;

  @override
  NavDrawerState createState() => NavDrawerState();
}

class NavDrawerState<StatefulWidget> extends State<NavDrawer> {
  bool isInitialized = false;

  double? _deviceHeight, _deviceWidth;
  String? currentBtnValue;
  Locale? currentLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    String currentPage = widget.currentPage;
    Locale locale = Localizations.localeOf(context);
    return Drawer(
      backgroundColor: "#063545".toColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _deviceHeight,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    "Budgetly".toUpperCase(),
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.home,
                    color: currentPage == 'tableau_recap_title'.i18n()
                        ? Colors.grey
                        : Colors.white,
                  ),
                  title: Text(
                    'tableau_recap_title'.i18n().toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      color: currentPage == 'tableau_recap_title'.i18n()
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                  onTap: () {
                    currentPage != 'tableau_recap_title'.i18n()
                        ? Navigator.of(context).pushNamed("/")
                        : "";
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.add,
                    color: currentPage == 'add_transaction_title'.i18n()
                        ? Colors.grey
                        : Colors.white,
                  ),
                  title: Text(
                    'add_transaction_title'.i18n().toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      color: currentPage == 'add_transaction_title'.i18n()
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                  onTap: () {
                    currentPage != 'add_transaction_title'.i18n()
                        ? Navigator.of(context).pushNamed("/addTransaction")
                        : "";
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.manage_search,
                    color: currentPage == 'tableau_general_title'.i18n()
                        ? Colors.grey
                        : Colors.white,
                  ),
                  title: Text(
                    'tableau_general_title'.i18n().toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      color: currentPage == 'tableau_general_title'.i18n()
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                  onTap: () {
                    currentPage != 'tableau_general_title'.i18n()
                        ? Navigator.of(context).pushNamed("/transactions")
                        : "";
                  },
                ),
                SizedBox(
                  height: _deviceHeight! * 0.05,
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: currentPage == 'settings_title'.i18n()
                        ? Colors.grey
                        : Colors.white,
                  ),
                  title: Text(
                    'label_settings'.i18n().toUpperCase(),
                    style: GoogleFonts.roboto(
                      color: currentPage == 'settings_title'.i18n()
                        ? Colors.grey
                        : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    // ignore: use_build_context_synchronously
                    currentPage != 'settings_title'.i18n()
                        ? Navigator.of(context).pushNamed("/settings")
                        : "";
                  },
                ),
                ListTile(
                  title: Text(
                    'label_disconnect'.i18n().toUpperCase(),
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("userId", "");
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamed("/login");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void changeLanguagePage(BuildContext context) {
    Locale newLocale = currentLocale == const Locale('en', 'EN')
        ? const Locale('fr', 'FR')
        : const Locale('en', 'EN');
    Get.updateLocale(newLocale);
    // print(newLocale);
    // setLocale(newLocale);
  }

  // changeLanguage(Locale locale) {
  //   setState(() {
  //     currentLocale = locale;
  //   });
  // }
}
