import 'package:go_router/go_router.dart';
import '../screens/todo_list_screen.dart';
import '../screens/todo_details_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TodoListScreen(),
      ),
      GoRoute(
        path: '/todo/:id',
        builder: (context, state) {
          final todoId = state.pathParameters['id']!;
          return TodoDetailScreen(todoId: todoId);
        },
      ),
    ],
  );
}
