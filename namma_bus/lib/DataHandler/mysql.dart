import 'package:mysql1/mysql1.dart';

class Mysql {
  var settings = new ConnectionSettings(
      host: '192.168.56.1',
      port: 3306,
      user: 'root',
      password: 'root',
      db: 'company');

  Mysql();

  Future<MySqlConnection> getConnection() async {
    print("HOOO");
    var conn = await MySqlConnection.connect(settings);

    return conn;
  }
}
