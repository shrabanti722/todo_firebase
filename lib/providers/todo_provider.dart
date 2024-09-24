import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

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
    final snapshot = await _firestore.collection('todos').get();
    state = snapshot.docs
        .map((doc) => Todo.fromJson(doc.data())
            .copyWith(id: doc.id))
        .toList();
  }

  Future<void> addTodo(Todo todo) async {
    await _firestore.collection('todos').add(todo.toJson());
    await fetchTodos();
  }

  Future<void> deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
    await fetchTodos();
  }
}

