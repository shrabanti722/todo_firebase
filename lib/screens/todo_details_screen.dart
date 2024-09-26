import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
  }
}
