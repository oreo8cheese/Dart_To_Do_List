import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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
        title: Text(_isSelectionMode ? '${_selectedTodos.length} selected' : 'Today\'s Tasks'),
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
              return TodoItem(
                todo: todo,
                isSelectionMode: _isSelectionMode,
                isSelected: _selectedTodos.contains(todo.id),
                onSelect: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                  }
                  _toggleTodoSelection(todo.id);
                },
              );
            },
          );
        },
      ),
    );
  }
} 