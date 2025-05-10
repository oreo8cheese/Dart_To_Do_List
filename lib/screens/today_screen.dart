import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final todayTodos = todoProvider.getTodayTodos();
          
          if (todayTodos.isEmpty) {
            return const Center(
              child: Text(
                'No tasks for today',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: todayTodos.length,
            itemBuilder: (context, index) {
              final todo = todayTodos[index];
              return TodoItem(todo: todo);
            },
          );
        },
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<TodoProvider>(context, listen: false)
            .deleteTodo(todo.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (bool? value) {
              Provider.of<TodoProvider>(context, listen: false)
                  .toggleTodoStatus(todo.id);
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: todo.description.isNotEmpty
              ? Text(todo.description)
              : null,
          trailing: Text(
            '${todo.dueDate.hour}:${todo.dueDate.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
} 