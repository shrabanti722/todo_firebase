import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class TodoDetailScreen extends ConsumerWidget {
  final String todoId;

  const TodoDetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(todoProviderProvider.select(
      (todos) => todos.firstWhere((t) => t.id == todoId),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(todo.description),
      ),
    );
  }
}
