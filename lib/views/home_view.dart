import 'package:flutter/material.dart';
import 'package:sqflite_deneme/core/constants/app_consts.dart';
import 'package:sqflite_deneme/core/database/database_helper.dart';
import 'package:sqflite_deneme/core/database/new_database_helper.dart';
import 'package:sqflite_deneme/core/extensions/size_extension.dart';
import 'package:sqflite_deneme/models/user_model.dart';

class HomeViewScreen extends StatefulWidget {
  const HomeViewScreen({super.key});

  @override
  State<HomeViewScreen> createState() => _HomeViewScreenState();
}

class _HomeViewScreenState extends State<HomeViewScreen> {
  int lastId = 0;
  @override
  void initState() {
    UserDataBaseService.instance.open();
    SqfliteDatabaseHelper.instance.getLastUserID().then((value) {
      setState(() {
        lastId = int.parse(value);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var date = DateTime.now();

    TextEditingController nameController = TextEditingController();
    TextEditingController idController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController genderController = TextEditingController();

    Future<List<UserModel>> getAllUsers =
        SqfliteDatabaseHelper.instance.getAllUsers();
    idController.text = "${lastId + 1}";

    //Future getUser = SqfliteDatabaseHelper.instance.getUser(idController.text);

    var dataHelper = SqfliteDatabaseHelper.instance;

    void addUserToDb() {
      UserModel user = UserModel(
          id: idController.text,
          name: nameController.text,
          password: passwordController.text,
          gender: genderController.text);

      dataHelper.insertUser(user);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Inventory",
          style: AppTextConstants()
              .smallTitleTextStyle(color: Colors.red, fsize: 25),
        ),
      ),
      body: Container(
          width: context.deviceWidht,
          height: context.deviceHeight,
          decoration: BoxDecoration(color: Colors.indigo.shade100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FutureBuilder(
                  future: getAllUsers,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            UserModel user = snapshot.data![index];
                            return ListTile(
                              leading: Text(user.gender),
                              title: Text(user.name),
                              subtitle: Text(user.password),
                              trailing: Text(user.id),
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Display an error message.
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Display a loading spinner.
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              const Text("evet"),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          scrollable:
                              true, //alertdialog taşmasını engellemek için
                          title: const Text("Kullanıcı Ekle"),
                          actions: [
                            TextField(
                              enabled: false,
                              controller: idController,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(label: Text("name")),
                              controller: nameController,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(label: Text("gender")),
                              controller: genderController,
                            ),
                            TextField(
                              decoration: const InputDecoration(
                                  label: Text("password")),
                              controller: passwordController,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    addUserToDb();
                                    lastId++;
                                    Navigator.pop(context);
                                  });
                                },
                                child: const Text("gönder"))
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("data getir"))
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            dataHelper.deleteUser("");
          });
        },
        child: const Text("ekle"),
      ),
    );
  }
}
