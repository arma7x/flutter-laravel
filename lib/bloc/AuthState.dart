import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthEvent {}

class UserLoggedIn extends AuthEvent {}

class UserLoggedOut extends AuthEvent {}

class AuthState extends Bloc<AuthEvent, bool> {
  /// {@macro counter_bloc}
  AuthState() : super(false) {
    on<UserLoggedIn>((event, emit) => emit(true));
    on<UserLoggedOut>((event, emit) => emit(false));
  }
}
