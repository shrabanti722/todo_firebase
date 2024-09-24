import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'package:go_router/go_router.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProviderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(todo.title),
            onTap: () {
              context.push('/todo/${todo.id}');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTodo = Todo(
                  id: '',
                  title: titleController.text,
                  description: descriptionController.text,
                );
                ref.read(todoProviderProvider.notifier).addTodo(newTodo);
                context.pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
