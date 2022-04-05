import 'package:flutter/material.dart';
import 'package:flutter_application_1/repositories/todo_repository.dart';

import '../models/todo.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  
  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;


  @override
  void initState(){
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
         todos = value;
      });
   
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(

          child: Padding(
         
            padding: const EdgeInsets.all(16),
          
            child: Column(
              mainAxisSize: MainAxisSize.min,
            
              children: [
                    SizedBox(
                  height: 26,
                ),
                 Expanded(
                           
                      child:
                     
                          Text("LISTA DE TAREFAS", style:TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                           

                          ) ,),
                    ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Adicione uma tarefa",
                            hintText: "Ex: Estudar Flutter",
                            errorText: errorText,
                            
                            ),
                            
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff00d7f3),
                        padding: EdgeInsets.all(18),
                      ),
                      onPressed: () {


                        String text = todoController.text;

                        if(text.isEmpty){
                          setState(() {
                             errorText = "O campo não popde ser vazio";
                          });
                         
                          return;
                        }

                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText =null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text("Você possui ${todos.length} tarefas pendentes"),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: deleteAllTodos,
                      child: Text("Limpar tudo"),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff00d7f3),
                        padding: EdgeInsets.all(18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



void deleteAllTodos() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Limpar tudo?'),
          content: Text('Deseja reamente apagar tudo?'),
          actions: [

            TextButton(onPressed: () {
              Navigator.of(context).pop();

            }, child: Text("Cancelar")),


            TextButton(onPressed: () {
              Navigator.of(context).pop();
              deleteAll();


            }, child: Text("Limpar tudo"))

          ],
        ),
      );
    }
  
  void deleteAll(){
    setState(() {
      todos.clear();
    });
     todoRepository.saveTodoList(todos);

  }

  void onDelete(Todo todo) {

    deletedTodo =todo;
    deletedTodoPos=todos.indexOf(todo);
    setState(() {
      todos.remove(todo);

    });
    todoRepository.saveTodoList(todos);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tarefa ${todo.title} foi removida com sucesso!"),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {

         setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);

         });
          todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5 ),
      ),
    );
  }
}
