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
        "CREATE TABLE $tableName ($columnId TEXT PRIMARY KEY, $columnName TEXT, $columnGender TEXT, $columnPassword TEXT)",
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
        print(userId);
      });
    } catch (e) {
      //print(e);
    }

    return userId;
  }

//son eklene userIdsini alıp işlem yapmak için
  Future<String> getLastUserID() async {
    Database db = await SqfliteDatabaseHelper.instance.getDataBase();
    var userId = await db.rawQuery(
        'SELECT $columnId FROM $tableName ORDER BY $columnId DESC LIMIT 1');
    String lastUserId = userId[0]["id"].toString();
    return lastUserId;
  }

  //sinlge user gösterim
  Future getUser(String userId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> user =
        await db.rawQuery("SELECT * FROM $tableName WHERE id = $userId");
    if (user.length == 1) {
      return UserModel(
          id: user[0]["id"],
          name: user[0]["name"],
          password: user[0]["password"],
          gender: user[0]["gender"]);
    } else {
      return user;
    }
  }

  //tüm datayı göstermek için
  Future<List<UserModel>> getAllUsers() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> usersMap = await db.query(tableName);
    return List.generate(usersMap.length, (index) {
      return UserModel(
          id: usersMap[index]["id"],
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
  Future<void> deleteUser(String userId) async {
    Database db = await getDataBase();
    await db.rawDelete("DELETE FROM $tableName WHERE id = '$userId'");
  }
}
