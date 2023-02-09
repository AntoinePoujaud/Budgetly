// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: const Color.fromARGB(51, 225, 232, 237),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible:
                false, // FR only tant que la feature de changement de langue ne fonctionne pas correctement
            child: SizedBox(
              height: _deviceHeight! * 0.03,
              width: _deviceWidth! * 0.02,
              child: MaterialButton(
                onPressed: (() {
                  changeLanguagePage(context);
                }),
                child: Text(
                  locale.toString() == 'fr_FR' ? "EN" : "FR",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
          SizedBox(
            height: _deviceHeight,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text(
                    currentPage,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(
                    'tableau_recap_title'.i18n(),
                    style: TextStyle(
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
                  leading: const Icon(Icons.add),
                  title: Text(
                    'add_transaction_title'.i18n(),
                    style: TextStyle(
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
                  leading: const Icon(Icons.manage_search),
                  title: Text(
                    'tableau_general_title'.i18n(),
                    style: TextStyle(
                      color: currentPage == 'tableau_general_title'.i18n()
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                  onTap: () {
                    currentPage != 'tableau_general_title'.i18n()
                        ? Navigator.of(context).pushNamed("/tableauGeneral")
                        : "";
                  },
                ),
                SizedBox(
                  height: _deviceHeight! * 0.64,
                ),
                ListTile(
                  title: Text(
                    'label_disconnect'.i18n(),
                    style: const TextStyle(
                      color: Colors.white,
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
