import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_deneme/models/user_model.dart';

class SqfliteDatabaseHelper {
  SqfliteDatabaseHelper.singleton();
  static final SqfliteDatabaseHelper instance =
      SqfliteDatabaseHelper.singleton();

  final String tableName = "userInfos";
  final String columnId = "id";
  final String columnName = "name";
  final String columnPassword = "password";
  final String columnGender = "gender";

//database açılış
  Future<Database> getDataBase() async {
    return openDatabase(join(await getDatabasesPath(), "usersData.db"),
        onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, $columnName TEXT, $columnGender TEXT, $columnPassword TEXT)",
      );
    }, version: 1);
  }

  //insert methodu
  Future<int> insertUser(UserModel user) async {
    int userId = 0;
    Database db = await getDataBase();
    try {
      await db.insert(tableName, user.toMap()).then((value) {
        userId = value;
      });
    } catch (e) {
      //print(e);
    }

    return userId;
  }

//son eklene userIdsini alıp işlem yapmak için
  Future<String> getLastUserID() async {
    Database db = await SqfliteDatabaseHelper.instance.getDataBase();
    String lastUserId;

    var userIds = await db.rawQuery(
        'SELECT $columnId FROM $tableName ORDER BY CAST($columnId AS INTEGER) DESC'); //Cast diyerek columnıd içindeki değerleri integer artan değer olarak sıralar

    if (userIds.isNotEmpty) {
      lastUserId = userIds[0]["id"].toString();
    } else {
      // Handle the case when the table is empty
      lastUserId = '0';
    }
    return lastUserId.toString();
  }

  Future getUserById(
    int id,
  ) async {
    final db = await getDataBase();

    await db.rawQuery("SELECT * FROM $tableName WHERE $columnId= '$id'").then(
      (value) {
        return UserModel(
            id: int.parse(value[0]["id"].toString()),
            name: value[0]["name"].toString(),
            gender: value[0]["gender"].toString(),
            password: value[0]["password"].toString());
      },
    );

    /* if (user.isNotEmpty) {
      return UserModel(
        id: int.parse(user[0]["id"]),
        name: user[0]["name"],
        password: user[0]["password"],
        gender: user[0]["gender"],
      );
    } else {
      throw Exception(
          "User not found"); // Handle the case when no user is found
    } */
  }

  //sinlge user gösterim
  /* Future getSingleUser() async {
    int id = 1;
    Database db = await getDataBase();

    var user = await db.query(tableName, where: columnId, whereArgs: [id]);

    print(user);

    return null; /* UserModel(
        id: int.parse(user[0]["id"]),
        name: user[0]["name"],
        password: user[0]["password"],
        gender: user[0]["gender"]); */
  } */

  //tüm datayı göstermek için
  Future<List<UserModel>> getAllUsers() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> usersMap = await db.query(tableName);

    return List.generate(usersMap.length, (index) {
      return UserModel(
          id: int.parse(usersMap[index]["id"]),
          name: usersMap[index]["name"],
          password: usersMap[index]["password"],
          gender: usersMap[index]["gender"]);
    });
  }

  //update methodu
  Future<void> updateUser(
      String userId, String name, String gender, String password) async {
    Database db = await getDataBase();
    db.rawUpdate(
        "UPDATE $tableName SET name = '$name', gender = '$gender', password = '$password'  WHERE id = '$userId'");
  }

  //delete
  Future<void> deleteUser(int userId) async {
    Database db = await getDataBase();
    await db.rawDelete("DELETE FROM $tableName WHERE id = '$userId'");
  }

  Future<void> deleteAllData() async {
    //clear data
    Database db = await getDataBase();
    await db.rawDelete('DELETE FROM $tableName');
  }
}
