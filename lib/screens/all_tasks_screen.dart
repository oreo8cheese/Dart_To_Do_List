import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  final Set<String> _selectedTodos = {};
  bool _isSelectionMode = false;

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTodos.clear();
      }
    });
  }

  void _toggleTodoSelection(String todoId) {
    setState(() {
      if (_selectedTodos.contains(todoId)) {
        _selectedTodos.remove(todoId);
        if (_selectedTodos.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTodos.add(todoId);
      }
    });
  }

  void _deleteSelectedTodos() {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    for (final todoId in _selectedTodos) {
      todoProvider.deleteTodo(todoId);
    }
    setState(() {
      _selectedTodos.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedTodos.length} selected' : 'All Tasks'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedTodos.isEmpty ? null : _deleteSelectedTodos,
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final todos = todoProvider.todos;
          
          if (todos.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Group todos by date
          final groupedTodos = <DateTime, List<Todo>>{};
          for (var todo in todos) {
            final date = DateTime(
              todo.dueDate.year,
              todo.dueDate.month,
              todo.dueDate.day,
            );
            if (!groupedTodos.containsKey(date)) {
              groupedTodos[date] = [];
            }
            groupedTodos[date]!.add(todo);
          }

          // Sort dates in descending order (newest first)
          final sortedDates = groupedTodos.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedDates.length * 2,
            itemBuilder: (context, index) {
              if (index.isEven) {
                // This is a date separator
                final date = sortedDates[index ~/ 2];
                final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
                final isToday = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).isAtSameMomentAs(date);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Text(
                    isToday ? 'Today' : dateFormat.format(date),
                    style: TextStyle(
                      color: isToday ? Theme.of(context).primaryColor : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                // This is a list of todos for the date
                final date = sortedDates[(index - 1) ~/ 2];
                final todosForDate = groupedTodos[date]!;
                
                return Column(
                  children: todosForDate.map((todo) => TodoItem(
                    todo: todo,
                    isSelectionMode: _isSelectionMode,
                    isSelected: _selectedTodos.contains(todo.id),
                    onSelect: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode();
                      }
                      _toggleTodoSelection(todo.id);
                    },
                  )).toList(),
                );
              }
            },
          );
        },
      ),
    );
  }
} 