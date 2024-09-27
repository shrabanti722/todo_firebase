import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProviderProvider);

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          GoRouter.of(context).go('/login');
        }
      });
      return const Center(child: CircularProgressIndicator());
    }

    final todosState = ref.watch(todoProviderProvider);


    final selectedTodos = todosState.maybeWhen(
      data: (todos) => todos.where((todo) => todo.selected).toList().cast<Todo>(),
      orElse: () => <Todo>[],
    );

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          GoRouter.of(context).go('/login');
        }
      });
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          if (_isSelectionMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  ref.read(todoProviderProvider.notifier).resetSelections();
                });
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
          if (selectedTodos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref
                    .read(todoProviderProvider.notifier)
                    .deleteSelectedTodos(selectedTodos);
                setState(() {
                  _isSelectionMode = false;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              ref.read(userProviderProvider.notifier).updateUser();
              if (context.mounted) {
                GoRouter.of(context).go('/login');
              }
            },
          ),
        ],
      ),
      body: todosState.when(
        data: (todos) => ReorderableListView(
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            ref.read(todoProviderProvider.notifier).moveTodo(oldIndex, newIndex);
            final updatedTodos = ref.read(todoProviderProvider).maybeWhen(
              data: (todos) => todos,
              orElse: () => <Todo>[],
            );
            ref.read(todoProviderProvider.notifier).updateTodosOrder(updatedTodos);
          },
          children: [
            for (final todo in todos)
              ListTile(
                key: ValueKey(todo.id),
                title: Text(todo.title, style: const TextStyle(color: Colors.white)),
                subtitle: todo.date != null
                    ? Text(
                        DateFormat('EEE, dd MMM \'at\' hh:mm a').format(todo.date!),
                        style: const TextStyle(color: Colors.grey),
                      )
                    : null,
                leading: _isSelectionMode
                    ? Checkbox(
                        value: todo.selected,
                        onChanged: (bool? value) {
                          ref.read(todoProviderProvider.notifier).toggleTodoSelection(todo);
                        },
                      )
                    : null,
                trailing: !_isSelectionMode
                    ? ReorderableDragStartListener(
                        index: todos.indexOf(todo),
                        child: const Icon(Icons.drag_handle),
                      )
                    : null,
                onLongPress: () {
                  setState(() {
                    _isSelectionMode = true;
                  });
                  ref.read(todoProviderProvider.notifier).toggleTodoSelection(todo);
                },
                onTap: () {
                  if (_isSelectionMode) {
                    ref.read(todoProviderProvider.notifier).toggleTodoSelection(todo);
                  } else {
                    context.push('/todo/${todo.id}');
                  }
                },
              ),
          ],
        ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoBottomSheet(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoBottomSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        DateTime? selectedDate;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Todo', style: TextStyle(fontSize: 18)),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'New Todo'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Add details'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedDate != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[500]!, width: 1),
                            ),
                            child: Text(
                              DateFormat('EEE, dd MMM \'at\' hh:mm a').format(selectedDate!),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
                        onPressed: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (!context.mounted) return;
                          if (date != null) {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              selectedDate = DateTime(
                                  date.year, date.month, date.day, time.hour, time.minute);
                              setModalState(() {});
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                            order: ref.read(todoProviderProvider).maybeWhen(
                              data: (todos) => todos.length,
                              orElse: () => 0,
                            ),
                            date: selectedDate,
                          );
                          ref.read(todoProviderProvider.notifier).addTodo(newTodo);
                          context.pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
