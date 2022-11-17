// ignore_for_file: file_names
import 'package:flutter/material.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key, required this.currentPage}) : super(key: key);
  final String currentPage;

  @override
  NavDrawerState createState() => NavDrawerState();
}

class NavDrawerState<StatefulWidget> extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    String currentPage = widget.currentPage;
    return Drawer(
      backgroundColor: const Color.fromARGB(51, 225, 232, 237),
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
              'Tableau récapitulatif',
              style: TextStyle(
                color: currentPage == 'Tableau récapitulatif'
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
            onTap: () => {
              currentPage != 'Tableau récapitulatif'
                  ? Navigator.pushNamed(context, "/")
                  : "",
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(
              'Ajouter transaction',
              style: TextStyle(
                color: currentPage == 'Ajouter transaction'
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
            onTap: () => {
              currentPage != 'Ajouter transaction'
                  ? Navigator.pushNamed(context, "/addTransaction")
                  : "",
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_search),
            title: Text(
              'Tableau Général',
              style: TextStyle(
                color: currentPage == 'Tableau Général'
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
            onTap: () => {
              currentPage != 'Tableau Général'
                  ? Navigator.pushNamed(context, "/tableauGeneral")
                  : "",
            },
          ),
        ],
      ),
    );
  }
}
