import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  TextEditingController taskController = TextEditingController();
  List<String> tasks = [];
  List<Map<String,dynamic>> jsonList=[];

  // loading data first time from the sharedpref..
  @override
  void initState() {
    super.initState();
    getTasks();
  }

  getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // when this function called from outside initstate, List must be cleared to prevent multiple entry of the same task
      // Stored data is in form of List<String> in sharedpreff... which is converted from List<Map>
      jsonList.clear();
      tasks = prefs.getStringList('tasks') ?? [];
      for(int i=0; i<tasks.length; i++){
        jsonList.add(jsonDecode(tasks[i]));
      }
    });
  }


  setTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: jsonList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(value: jsonList.elementAt(index)["isCompleted"],
                      onChanged: (value){
                    jsonList[index]["isCompleted"]=!jsonList[index]["isCompleted"];
                    tasks[index]= jsonEncode(jsonList[index]);
                    setState(() {
                      setTasks();
                    });
                      }),
                  title: Text(jsonList.elementAt(index)["task"]),
                  trailing:IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        tasks.removeAt(index);
                        jsonList.removeAt(index);
                        setTasks();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a task',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // convert data into map and map to String and storing in sharedpref..
                ElevatedButton(
                  onPressed: () {
                    final task=taskController.text.trim()=="" ?"Task : ${jsonList.length+1}" : taskController.text.trim();
                      Map<String,dynamic> data= {
                        "task" : "$task",
                        "isCompleted" : false,
                      };
                      String stringJson = jsonEncode(data);
                      tasks.add(stringJson);
                      jsonList.add(data);
                      taskController.clear();
                      setTasks();
                    setState(() {});
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
