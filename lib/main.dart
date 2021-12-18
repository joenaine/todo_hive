import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newvers/todo_model.dart';
import 'package:path_provider/path_provider.dart';

import 'home.dart';

const String todoBoxName = 'todo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationSupportDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home());
  }
}
