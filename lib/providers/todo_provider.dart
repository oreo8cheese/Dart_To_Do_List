import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  TodoProvider() {
    _loadTodos();
  }

  List<Todo> getTodayTodos() {
    final now = DateTime.now();
    return _todos.where((todo) {
      final todoDate = todo.dueDate;
      return todoDate.year == now.year &&
          todoDate.month == now.month &&
          todoDate.day == now.day;
    }).toList();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos') ?? [];
    _todos = todosJson
        .map((todoJson) => Todo.fromJson(json.decode(todoJson)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = _todos
        .map((todo) => json.encode(todo.toJson()))
        .toList();
    await prefs.setStringList('todos', todosJson);
  }

  void addTodo(Todo todo) {
    _todos.add(todo);
    _saveTodos();
    notifyListeners();
  }

  void updateTodo(Todo todo) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _saveTodos();
    notifyListeners();
  }

  void toggleTodoStatus(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      _saveTodos();
      notifyListeners();
    }
  }
} 