// imports material package from dart which gives us access to a lot of nice Flutter widgets/classes like MaterialApp and more 
import 'package:flutter/material.dart';

// holds information about each task in the list 
class Todo {
  Todo({required this.name, required this.checked});
  // name of each class
  final String name; 
  // whether of not each class is checked
  bool checked; 
}

// main function returns an instance of our TodoApp class below 
void main() => runApp(
  new TodoApp(),
);

// top-level container for our todo list 
// is a stateless widget because we don't need to interact with the container
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // use the predefined flutter class MaterialApp
    // allows us to access components and widgets provided by Flutter: AppBar, Scaffold etc.
    return new MaterialApp(
      // title of app 
      title: 'Todo List',
      // our home widget will be an instance of the TodoList class below (a stateful widget)
      home: new TodoList(),
    );
  }
}

// TodoList is a stateful widget (which means we can interact) 
// it holds the state _TodoListState as defined below 
// note: state is info that can be read when widget is build and can change during lifetime of a widget
class TodoList extends StatefulWidget {
  @override 
  _TodoListState createState() => new _TodoListState();
}

// implements State for the stateful widget TodoList
class _TodoListState extends State<TodoList> {
  // provides the editable textbox for proposing new tasks 
  final TextEditingController _textFieldController = TextEditingController();
  // holds a list of Todo objects (as defined above)
  // this is basically what remembers all the tasks we want to put on our todo list 
  final List<Todo> _todos = <Todo>[];

  @override
  // defines how the page looks 
  Widget build(BuildContext context) {
    // Scaffold implements the basic Material Design visual layout structure 
    // holds all the pieces (AppBar, text, etc.)
    return new Scaffold(
      // implements the blue title at the top 
      appBar: new AppBar(
        // populates the appBar with words 
        title: new Text('Todo List'),
      ),
      // dictates how rest of page looks 
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        // the children of the Scaffold are each of the Todo objects 
        // unpack the list of Todo objects by using asMap which returns (key, val) pairs of everything in the _todos list defined above 
        // keys are the indices, the vals are the actual Todo object 
        children: _todos.asMap().entries.map((entry) {
          // create an instance of the TodoItem class (defined below)
          // populate with the relevant attributes 
          return TodoItem(
            todo: entry.value, 
            onTodoChanged: _handleTodoChange,
            deleteFunction: _deleteTodo,
            idx: entry.key,
          );
        }).toList(),
      ),
      // Implements the plus button at the bottom right 
      floatingActionButton: FloatingActionButton(
        // when the button is pressed, call the function _displayDialog (implemented below)
        // a function which makes a form appear asking user to "Add a new todo item"
        onPressed: () => _displayDialog(), 
        // when hovering over the plus button, display the helpful hint "Add Item"
        tooltip: 'Add Item', 
        // implements the plus icon on the button
        child: Icon(Icons.add)), 
    );
  }
  // other functions
  // the function which displays the dialog box/form asking for new todos 
  Future<void> _displayDialog() async {
    // showDialog is a function from material which displays a Material dialog box 
    // call it with inputs context, barrierDismissible, and the anonymous function builder 
    return showDialog<void>(
      // used to look up Navigator/Theme for dialog
      context: context, 
      // tapping barrier has no effect
      barrierDismissible: false,
      // define the anonymous function builder 
      // takes in context as input 
      builder: (BuildContext context) {
        // returns a dialog box (an instance of the class AlertDialog provided by Flutter)
        return AlertDialog(
          // dialog box has a title prompting users to add a new item 
          title: const Text('Add a new todo item'),
          // dialog box has a place to input text (name of new task)
          content: TextField(
            controller: _textFieldController,
            // prefilled with "Type your new todo"
            decoration: const InputDecoration(hintText: 'Type your new todo'),
          ),
          // the add button at the bottom right 
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              // when add button is pressed, the _addTodoItem function is called with an input of _textFieldController.text (gets the text that the user just type in)
              // _addTodoItem function then takes this input to create a Todo object and add it to _todos, thus adding this new task to our todo list 
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }
  // function which deletes the Todo object at the index idx from the _todos list 
  void _deleteTodo(int idx) {
    setState(() {
      _todos.removeAt(idx);
    });
  }

  // function which keeps track of whether or not a task is checked (crossed out) by toggling the checked attribute of the Todo object  
  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.checked = !todo.checked;
    });
  }

  // function which adds a todo item to the _todos list 
  void _addTodoItem(String name) {
    setState(() {
      // adds the Todo object to _todos after populating it with the name of the task and setting checked to false 
      _todos.add(Todo(name: name, checked: false));
    });
    // user friendly: clears the text input box which asks for new todos 
    _textFieldController.clear();
  }
}

// a wrapper class for the Todo objects 
class TodoItem extends StatelessWidget {
  TodoItem({
    // the Todo object which remembers name and whether task is checked 
    required this.todo, 
    // the function which crosses out the task 
    required this.onTodoChanged,
    // function which deletes the task 
    required this.deleteFunction,
    // index of the task/Todo in the list _todos
    // this is how we find the index of the Todo we want to delete from the list _todos 
    required this.idx,
  }) : super(key: ObjectKey(todo));

  // final key word hardcodes values of the variables and functions 
  final Todo todo; 
  final onTodoChanged;
  final deleteFunction;
  final int idx;

  // function which crosses the task out if checked is true
  // else just displays the task as is 
  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override 
  Widget build(BuildContext context) {
    // the widget that actually displays the task and its corresponding icons (like the circle before it and the trash can after it)
    return ListTile(
      // when you click the row/tile a particular task is in, onTodoChanged is called which crosses it out
      onTap: () {
        onTodoChanged(todo); 
      }, 
      // the circle icon which precedes it and starts with the first letter of the task name
      leading: CircleAvatar(
        child: Text(todo.name[0]),
      ),
      // holds the name of the task in the style _getTextStyle (function which crosses the task name out if todo.checked is True, implemented above)
      title: Text(todo.name, style: _getTextStyle(todo.checked)),
      // the trash icon at the end 
      trailing: IconButton(
        // when trash icon is pressed, delete the task with the corresponding index from the _todos list and thus the whole todo list by calling deleteFunction (written above)
        onPressed: () {
          deleteFunction(idx);
          },
          // Icon class from material library 
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          // when hovering over the trash can, give helpful hint of 'delete comment'
          tooltip: 'Delete comment',
        ),
    );
  }
}

