import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import 'user_provider.dart';

part 'todo_provider.g.dart';

@riverpod
class TodoProvider extends _$TodoProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  List<Todo> build() {
    fetchTodos();
    return [];
  }

  Future<void> fetchTodos() async {
    final user = ref.read(userProviderProvider);
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .orderBy('order')
          .get();
      state = snapshot.docs
          .map((doc) => Todo.fromJson(doc.data()).copyWith(id: doc.id))
          .toList();
    }
  }

  Future<void> addTodo(Todo todo) async {
    final user = ref.read(userProviderProvider);
    if (user != null) {
      final todos = state;
      final newOrder = todos.isEmpty ? 0 : todos.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .add(todo.copyWith(order: newOrder).toJson());
      await fetchTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    final user = ref.read(userProviderProvider);
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .doc(id)
          .delete();
      await fetchTodos();
    }
  }

  Future<void> updateTodosOrder(List<Todo> todos) async {
    final user = ref.read(userProviderProvider);
    if (user != null) {
      final batch = _firestore.batch();

      print(todos);

      for (final todo in todos) {
        final todoRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('todos')
            .doc(todo.id);
        batch.update(todoRef, {'order': todo.order});
      }

      await batch.commit();
    }
  }

  void moveTodo(int oldIndex, int newIndex) {
  final todos = List.of(state);
  var movedTodo = todos.removeAt(oldIndex);
  movedTodo = movedTodo.copyWith(order: newIndex);  
  todos.insert(newIndex, movedTodo);  
  for (int i = 0; i < todos.length; i++) {
    todos[i] = todos[i].copyWith(order: i);
  }
  state = todos;
}

Future<void> deleteSelectedTodos(List<Todo> selectedTodos) async {
  final user = ref.read(userProviderProvider);
  if (user != null && selectedTodos.isNotEmpty) {
    final batch = _firestore.batch();

    for (final todo in selectedTodos) {
      final todoRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .doc(todo.id);
      batch.delete(todoRef);
    }

    await batch.commit();
    await fetchTodos();
  }
}

void toggleTodoSelection(Todo todo) {
  final todos = List.of(state);
  final index = todos.indexOf(todo);
  if (index != -1) {
    todos[index] = todos[index].copyWith(selected: !todos[index].selected);
    state = todos;
  }
}

void resetSelections() {
  state = state.map((todo) => todo.copyWith(selected: false)).toList();
}
}
