import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/models/todo.dart';
import '../providers/todo_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class TodoDetailScreen extends ConsumerWidget {
  final String todoId;

  const TodoDetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(todoProviderProvider);

    return todosState.when(
      data: (todos) {
        final todo = todos.firstWhere(
          (t) => t.id == todoId,
          orElse: () => const Todo(id: '', title: 'Not Found', description: 'Todo not found', order: 0),
        );

        if (todo.title == 'Not Found') {
          return Scaffold(
            appBar: AppBar(title: const Text('Todo Not Found')),
            body: const Center(child: Text('Todo not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(todo.title, style: const TextStyle(color: Colors.white)),
            automaticallyImplyLeading: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    GoRouter.of(context).go('/login');
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(todo.description, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $error'),
            TextButton(
              onPressed: () {
                ref.invalidate(todoProviderProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
