import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              return Provider.of<TodoProvider>(context, listen: false)
                  .todos
                  .where((todo) => isSameDay(todo.dueDate, day))
                  .toList();
            },
            calendarStyle: const CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                final selectedDayTodos = _selectedDay == null
                    ? []
                    : todoProvider.todos
                        .where((todo) => isSameDay(todo.dueDate, _selectedDay!))
                        .toList();

                if (_selectedDay == null) {
                  return const Center(
                    child: Text('Select a day to view tasks'),
                  );
                }

                if (selectedDayTodos.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: selectedDayTodos.length,
                  itemBuilder: (context, index) {
                    final todo = selectedDayTodos[index];
                    return TodoItem(todo: todo);
                  },
                );
              },
            ),
          ),
        ],
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