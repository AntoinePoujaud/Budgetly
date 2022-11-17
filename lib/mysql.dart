import 'package:mysql_client/mysql_client.dart';

class Mysql {
  static String host = 'localhost',
      user = 'root',
      password = 'root',
      db = 'budgetly';
  static int port = 3306;

  Mysql();

  Future<MySQLConnection> getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: db,
    );
    await conn.connect();
    return conn;
  }
}
