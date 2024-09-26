import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'user_provider.g.dart';

@riverpod
class UserProvider extends _$UserProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  User? build() {
    return _firebaseAuth.currentUser;
  }

  void updateUser() {
    state = _firebaseAuth.currentUser;
  }
}