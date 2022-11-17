import 'package:budgetly/ajoutTransaction.dart';
import 'package:budgetly/tableauGeneral.dart';
import 'package:flutter/material.dart';
import 'tableauRecap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var routes = {
      "/": (context) => const TableauRecap(title: "Tableau récapitulatif"),
      "/addTransaction": (context) =>
          const AjoutTransaction(title: "Ajouter transaction"),
      "/tableauGeneral": (context) =>
          const TableauGeneral(title: "Tableau Général"),
    };
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      // routes: routes,
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
            pageBuilder: (_, a1, a2) => routes[settings.name]!(context));
      },
    );
  }
}
