import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:newvers/main.dart';
import 'package:newvers/todo_model.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

enum TodoFilter { ALL, COMPLETED, INCOMPLETED }

class _HomeState extends State<Home> {
  Box<TodoModel> todoBox;

  List<String> sort = [
    'All',
    'Completed',
    'Incompleted',
  ];
  int _sliding = 0;

  TodoFilter filter = TodoFilter.ALL;

  @override
  void initState() {
    super.initState();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  /// @2handaulet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf2f1f6),
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFf2f1f6),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Container(
                  height: 120,
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(hintText: 'Title'),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: detailController,
                        decoration: InputDecoration(hintText: 'Description'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: TextButton(
                      onPressed: () {
                        final String title = titleController.text;
                        final String detail = detailController.text;

                        TodoModel todo = TodoModel(
                            title: title, detail: detail, isCompleted: false);
                        todoBox.add(todo);

                        Navigator.pop(context);
                      },
                      child: Text('Add Todo', style: TextStyle(fontSize: 16),),
                    ),
                  )
                ],
              );
            },
          );
          titleController.clear();
          detailController.clear();
        },
        elevation: 2,
        child: Icon(
          CupertinoIcons.add,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl(
              children: {
                0: Text('All'),
                1: Text('Completed'),
                2: Text('Incompleted'),
              },
              groupValue: _sliding,
              onValueChanged: (newValue) {
                setState(() {
                  _sliding = newValue;
                  if (newValue == 0) {
                setState(() {
                  filter = TodoFilter.ALL;
                });
              } else if (newValue == 1) {
                setState(() {
                  filter = TodoFilter.COMPLETED;
                });
              } else {
                setState(() {
                  filter = TodoFilter.INCOMPLETED;
                });
              }
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width / 1.03,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: ValueListenableBuilder(
                  valueListenable: todoBox.listenable(),
                  builder: (context, Box<TodoModel> todos, _) {
                    List<int> keys;

                    if (filter == TodoFilter.ALL) {
                      keys = todos.keys.cast<int>().toList();
                    } else if (filter == TodoFilter.COMPLETED) {
                      keys = todos.keys
                          .cast<int>()
                          .where((key) => todos.get(key).isCompleted)
                          .toList();
                    } else {
                      keys = todos.keys
                          .cast<int>()
                          .where((key) => !todos.get(key).isCompleted)
                          .toList();
                    }

                    return ListView.separated(
                      physics: AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final int key = keys[index];
                        final TodoModel todo = todos.get(key);

                        return ListTile(
                          title: Text(todo.title),
                          subtitle: Text(todo.detail),
                          leading: IconButton(
                              onPressed: () {
                                setState(() {
                                  TodoModel mTodo = TodoModel(
                                      title: todo.title,
                                      detail: todo.detail,
                                      isCompleted: true);
                                  todoBox.put(key, mTodo);
                                });
                              },
                              icon: !todo.isCompleted
                                  ? Icon(CupertinoIcons.circle)
                                  : Icon(CupertinoIcons.check_mark_circled)),
                                  trailing: IconButton(onPressed: (){
                                    todoBox.deleteAt(index);
                                  }, icon: Icon(CupertinoIcons.delete)),
                          
                        );
                      },
                      separatorBuilder: (_, index) => Divider(height: 2),
                      itemCount: keys.length,
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
