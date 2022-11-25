import 'package:budgetly/ajoutTransaction.dart';
import 'package:budgetly/tableauGeneral.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'tableauRecap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // set json file directory
    // default value is ['lib/i18n']
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    var routes = {
      "/": (context) => TableauRecap(title: 'tableau_recap_title'.i18n()),
      "/addTransaction": (context) =>
          AjoutTransaction(title: 'add_transaction_title'.i18n()),
      "/tableauGeneral": (context) =>
          TableauGeneral(title: 'tableau_general_title'.i18n()),
    };
    return MaterialApp(
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }

        // define pt_BR as default when de language code is 'pt'
        if (locale?.languageCode == 'fr') {
          return const Locale('fr', 'FR');
        }

        // default language
        return const Locale('en', 'EN');
      },
      localizationsDelegates: [
        // delegate from flutter_localization
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // delegate from localization package
        LocalJsonLocalization.delegate,
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/tableauGeneral",
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
            pageBuilder: (_, a1, a2) => routes[settings.name]!(context));
      },
    );
  }
}
