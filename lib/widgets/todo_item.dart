import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../screens/todo_detail_screen.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final bool isSelected;
  final VoidCallback? onSelect;
  final bool isSelectionMode;

  const TodoItem({
    super.key,
    required this.todo,
    this.isSelected = false,
    this.onSelect,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onLongPress: onSelect,
        onTap: isSelectionMode
            ? onSelect
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoDetailScreen(todo: todo),
                  ),
                );
              },
        child: ListTile(
          leading: isSelectionMode
              ? GestureDetector(
                  onTap: onSelect,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected ? Colors.red.withOpacity(0.1) : null,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.remove,
                              color: Colors.red,
                              size: 16,
                            ),
                          )
                        : null,
                  ),
                )
              : Checkbox(
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
          trailing: Text(
            DateFormat('h:mm a').format(todo.dueDate),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
} 