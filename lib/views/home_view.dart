import 'package:flutter/material.dart';
import 'package:sqflite_deneme/core/constants/app_consts.dart';

import 'package:sqflite_deneme/core/database/new_database_helper.dart';
import 'package:sqflite_deneme/core/extensions/size_extension.dart';
import 'package:sqflite_deneme/models/user_model.dart';

class HomeViewScreen extends StatefulWidget {
  const HomeViewScreen({super.key});

  @override
  State<HomeViewScreen> createState() => _HomeViewScreenState();
}

String selectedValue = "male";
var genders = ["male", "female"];

class _HomeViewScreenState extends State<HomeViewScreen> {
  int lastId = 0; //lastId değişkeni başta 0

  SqfliteDatabaseHelper dataHelper = SqfliteDatabaseHelper.instance;

  @override
  void initState() {
    lastUserId();

    super.initState();
  }

  lastUserId() {
    SqfliteDatabaseHelper.instance.getLastUserID().then((value) {
      setState(() {
        if (value.isNotEmpty) {
          lastId = int.parse(value) + 1;
        } else {
          lastId = 0;
        }
        //burda databaseden aldığımız son kullanıcı ıdsini lastId değişkenine verdik
      });
    }).catchError((e) {
      noUserAlert();
    });
  }

  noUserAlert() {
    return showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text("There is no data in database"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController idController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    Future<List<UserModel>> getAllUsers =
        SqfliteDatabaseHelper.instance.getAllUsers();

    idController.text =
        "$lastId"; //ıd gösteren Textfielda gelen lastId yi deklare ettik

    //database e user bilgilerini göndermek için method oluşturduk
    void addUserToDb() {
      UserModel user = UserModel(
          id: int.parse(idController.text),
          name: nameController.text,
          password: passwordController.text,
          gender: selectedValue);

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
              AllDataShow(getAllUsers: getAllUsers),
              const Text("evet"),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
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
                              SizedBox(
                                  width: context.deviceWidht,
                                  child: DropdownButton<String>(
                                    icon: selectedValue == "male"
                                        ? const Icon(Icons.male)
                                        : const Icon(Icons.female),
                                    value: selectedValue,
                                    items: genders.map((items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue = newValue.toString();
                                      });
                                    },
                                  )),
                              TextField(
                                decoration: const InputDecoration(
                                    label: Text("password")),
                                controller: passwordController,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      addUserToDb();
                                      lastId++; //lastID bir future döndüğü için burda manuel olarak eklediğimiz her kullanıcı sonrası ıd yi arttırdık yoksa sabit kalıyor
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text("gönder"))
                            ],
                          );
                        });
                      },
                    );
                  },
                  child: const Text("data getir"))
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            for (int i = 13; i > 7; i--) {
              dataHelper.deleteUser(i);
            }

            //dataHelper.deleteAllData();
            //lastId = 1;
          });
        },
        child: const Text("ekle"),
      ),
    );
  }
}

class AllDataShow extends StatelessWidget {
  const AllDataShow({
    super.key,
    required this.getAllUsers,
  });

  final Future<List<UserModel>> getAllUsers;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    trailing: Text(user.id.toString()),
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
    );
  }
}
