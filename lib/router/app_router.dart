import 'package:go_router/go_router.dart';
import 'package:todo/screens/login_page.dart';
import '../screens/todo_list_screen.dart';
import '../screens/todo_details_screen.dart';
import '../screens/sign_up_page.dart';

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
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
    ],
  );
}
