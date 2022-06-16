import 'package:flutter_bloc/flutter_bloc.dart';

/*
 * @type
 * 0 => guest
 * 1 => laravel_authentication
 * 2 => firebase_authentication
*/

enum UserType { guest, laravel, firebase }

class UserState extends Cubit<Map<String, dynamic>> {

    static Map<String, dynamic> dummy = {
        "name": "Guest",
        "email": "Please login",
        "type": UserType.guest,
    };

    UserState() : super(dummy);

    void saveUser(Map<String, dynamic> info) {
        emit(info);
    }

    void removeUser() {
        emit(dummy);
    }
}
