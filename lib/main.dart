import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shruti\'s To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(secondary: Colors.amber),
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> todos = [];

  TextEditingController todoController = TextEditingController();
  TextEditingController editingController = TextEditingController();

  int selectedIndex = -1;

  String filter = '';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todos = prefs.getStringList('todos') ?? [];
    });
  }

  _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', todos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  filter = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search todo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: todos.isEmpty && filter.isNotEmpty
                ? Center(child: Text('No matching todos found'))
                : todos.isEmpty
                ? Center(child: Text('No todos added yet'))
                : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                if (filter.isNotEmpty && !todos[index].toLowerCase().contains(filter.toLowerCase())) {
                  return SizedBox.shrink();
                }
                return Dismissible(
                  key: Key(todos[index]),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      todos.removeAt(index);
                    });
                    _saveTodos();
                  },
                  child: Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: ListTile(
                      title: Text(
                        todos[index],
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          editingController.text = todos[index];
                        });
                        _editTodoItem(context);
                      },
                      trailing: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
                    ),
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
                    controller: todoController,
                    decoration: InputDecoration(
                      hintText: 'Enter todo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (selectedIndex == -1) {
                      setState(() {
                        todos.add(todoController.text);
                        todoController.clear();
                      });
                    } else {
                      setState(() {
                        todos[selectedIndex] = todoController.text;
                        selectedIndex = -1;
                        todoController.clear();
                      });
                    }
                    _saveTodos();
                  },
                  child: Text(selectedIndex == -1 ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editTodoItem(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: TextField(
            controller: editingController,
            decoration: InputDecoration(
              hintText: 'Edit your todo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (editingController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Todo cannot be empty!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
