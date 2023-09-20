import 'package:sqflite/sqflite.dart';

import '../../models/user_model.dart';

class UserDataBaseService {
  UserDataBaseService.init();
  static final UserDataBaseService instance = UserDataBaseService.init();

  final String _userDatabaseName = "users";
  final String usersTable = "userInfos";
  Database? database;

  String columnId = "id";

  Future<void> open() async {
    database = await openDatabase(
      version: 1,
      _userDatabaseName,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE $usersTable ($columnId TEXT PRIMARY KEY, name TEXT, gender TEXT, password TEXT)",
        );
      },
    );
  }

  Future<List<UserModel>> getAllUsers(Database db) async {
    var userList = await db.query('users');
    return userList.map((userMap) => UserModel.fromMap(userMap)).toList();
  }

  Future<int> insertUser(UserModel user, Database db) async {
    var id = await db.insert('users', user.toMap());

    user.id = id.toString();
    return id;
  }

  Future getUserId(Database db) async {
    var userId = await db.rawQuery('SELECT $columnId FROM  $usersTable ');
    return userId;
  }

  Future<int> updateUser(UserModel user, Database db) async {
    return await db
        .update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id, Database db) async {
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
