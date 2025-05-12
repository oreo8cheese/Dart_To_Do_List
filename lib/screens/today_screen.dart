import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  bool _showUpcoming = false;

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
        title: Text(_isSelectionMode ? '${_selectedTodos.length} selected' : 'Today'),
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

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));

          final todayTodos = todos.where((todo) {
            final todoDate = DateTime(
              todo.dueDate.year,
              todo.dueDate.month,
              todo.dueDate.day,
            );
            return todoDate.isAtSameMomentAs(today);
          }).toList();

          final upcomingTodos = todos.where((todo) {
            final todoDate = DateTime(
              todo.dueDate.year,
              todo.dueDate.month,
              todo.dueDate.day,
            );
            return todoDate.isAfter(today);
          }).toList();

          return ListView(
            children: [
              ...todayTodos.map((todo) => TodoItem(
                todo: todo,
                isSelectionMode: _isSelectionMode,
                isSelected: _selectedTodos.contains(todo.id),
                onSelect: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                  }
                  _toggleTodoSelection(todo.id);
                },
              )),
              if (upcomingTodos.isNotEmpty) ...[
                const Divider(height: 32),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showUpcoming = !_showUpcoming;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Upcoming (${upcomingTodos.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _showUpcoming ? Icons.expand_less : Icons.expand_more,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showUpcoming)
                  ...upcomingTodos.map((todo) => TodoItem(
                    todo: todo,
                    isSelectionMode: _isSelectionMode,
                    isSelected: _selectedTodos.contains(todo.id),
                    onSelect: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode();
                      }
                      _toggleTodoSelection(todo.id);
                    },
                  )),
              ],
            ],
          );
        },
      ),
    );
  }
} 