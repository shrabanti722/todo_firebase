import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import 'user_provider.dart';

part 'todo_provider.g.dart';

@riverpod
class TodoProvider extends _$TodoProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Timer? _timer;

  @override
  AsyncValue<List<Todo>> build() {
    state = const AsyncValue.loading();
    fetchTodos();
    _startMidnightCheckTimer();
    return state;
  }

  //  @override
  // AsyncValue<List<Todo>> build() {
  //   state = const AsyncValue.loading();

  //   ref.listen<User?>(userProviderProvider, (previous, user) async {
  //     if (user == null) {
  //       state = const AsyncData([]);
  //       return;
  //     } 
  //       await fetchTodos();
  //   });
  //   _startMidnightCheckTimer();
  //   return state;
  // }

  void _startMidnightCheckTimer() {
    Timer.periodic(const Duration(minutes: 5), (_) {
      _checkMidnight();
    });
  }

  void _checkMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);

    if (now.isAfter(midnight)) {
      ref.invalidate(todoProviderProvider);
    }
  }

  Future<void> fetchTodos() async {
    final user = ref.watch(userProviderProvider);
    if (user != null) {
      try {
        final Timestamp now = Timestamp.fromDate(DateTime.now());

        final Timestamp yesterday = Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('todos')
            // .where('date', isLessThan: now, isGreaterThan: yesterday)
            .orderBy('order')
            .get();

        state = AsyncData(
          snapshot.docs
              .map((doc) => Todo.fromJson(doc.data()).copyWith(id: doc.id))
              .toList(),
        );
      } catch (e, stackTrace) {
        state = AsyncError(e, stackTrace);
      }
    } else {
      state = const AsyncData([]);
    }
  }

  Future<void> addTodo(Todo todo) async {
    final user = ref.read(userProviderProvider);
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .add(todo.toJson());
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
    final todos = List<Todo>.of(state.value ?? []);
    var movedTodo = todos.removeAt(oldIndex);
    movedTodo = movedTodo.copyWith(order: newIndex);
    todos.insert(newIndex, movedTodo);
    for (int i = 0; i < todos.length; i++) {
      todos[i] = todos[i].copyWith(order: i);
    }
    state = AsyncData(todos);
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
    final todos = List<Todo>.of(state.value ?? []);
    final index = todos.indexOf(todo);
    if (index != -1) {
      todos[index] = todos[index].copyWith(selected: !todos[index].selected);
      state = AsyncData(todos);
    }
  }

  void resetSelections() {
    final todos = state.value ?? [];
    state = AsyncData(
      todos.map((todo) => todo.copyWith(selected: false)).toList(),
    );
  }
}
