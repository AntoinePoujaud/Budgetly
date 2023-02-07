import 'package:budgetly/pages/ajoutTransactionPage.dart';
import 'package:budgetly/pages/signinPage.dart';
import 'package:budgetly/pages/tableauGeneralPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'pages/loginPage.dart';
import 'pages/mainPage.dart';
import 'package:get/get.dart';

void main()async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
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
          MainPage(title: 'tableau_general_title'.i18n()),
      "/login": (context) => const LoginPage(title: 'Se connecter'),
      "/signIn": (context) => const SignInPage(title: "S'inscrire"),
    };
    return GetMaterialApp(
      supportedLocales: const [
        Locale('en', 'EN'),
        // Locale('fr', 'FR'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }

        // define fr_FR as default when de language code is 'fr'
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
      title: 'Budgetly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/login",
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
            pageBuilder: (_, a1, a2) => routes[settings.name]!(context));
      },
    );
  }
}
