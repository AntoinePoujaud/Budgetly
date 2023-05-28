import 'package:budgetly/pages/settings.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:localization/localization.dart';

import 'pages/addTransaction.dart';
import 'pages/forgottenPassword.dart';
import 'pages/login.dart';
import 'pages/homepage.dart';
import 'pages/regeneratePassword.dart';
import 'pages/signinPage.dart';
import 'pages/transactions.dart';

class Routes {
  static final router = FluroRouter();
  static var loginHandler = Handler(handlerFunc: ((context, parameters) {
    return const Login(title: 'Se connecter');
  }));
  static var signInHandler = Handler(handlerFunc: ((context, parameters) {
    return const SignInPage(title: "S'inscrire");
  }));
  static var addTransactionHandler =
      Handler(handlerFunc: ((context, parameters) {
    return AddTransaction(title: 'add_transaction_title'.i18n());
  }));
  static var tableauGeneralHandler =
      Handler(handlerFunc: ((context, parameters) {
    return Transactions(title: 'tableau_general_title'.i18n());
  }));
  static var homeHandler = Handler(handlerFunc: ((context, parameters) {
    return Home(title: 'tableau_recap_title'.i18n());
  }));
  static var settingsHandler = Handler(handlerFunc: ((context, parameters) {
    return SettingsPage(title: 'settings_title'.i18n());
  }));
  static var forgotPasswordHandler =
      Handler(handlerFunc: ((context, parameters) {
    return const ForgottenPassword(title: "Mdp oublie");
  }));
  static var regeneratePasswordHandler =
      Handler(handlerFunc: ((context, parameters) {
    final args = (ModalRoute.of(context!)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    return RegeneratePassword(title: "Nouveau mdp", argsEmail: args["email"]);
  }));
  static var nothingReturnedHandler =
      Handler(handlerFunc: ((context, parameters) {
    return null;
  }));

  static dynamic defineRoutes() {
    router.define("/homepage",
        handler: homeHandler, transitionType: TransitionType.none);
    router.define("/addTransaction",
        handler: addTransactionHandler, transitionType: TransitionType.none);
    router.define("/transactions",
        handler: tableauGeneralHandler, transitionType: TransitionType.none);
    router.define("/login",
        handler: loginHandler, transitionType: TransitionType.none);
    router.define("/signIn",
        handler: signInHandler, transitionType: TransitionType.none);
    router.define("/forgotPassword",
        handler: forgotPasswordHandler, transitionType: TransitionType.none);
    router.define("/forgotPassword/newPassword",
        handler: regeneratePasswordHandler,
        transitionType: TransitionType.none);
    router.define("/settings",
        handler: settingsHandler, transitionType: TransitionType.none);
    router.define("/",
        handler: nothingReturnedHandler, transitionType: TransitionType.none);
  }
}
