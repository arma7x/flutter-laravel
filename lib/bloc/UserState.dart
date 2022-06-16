import 'package:flutter_bloc/flutter_bloc.dart';

/*
 * @type
 * 0 => guest
 * 1 => laravel_authentication
 * 2 => firebase_authentication
*/
class UserState extends Cubit<Map<String, dynamic>> {

    static int guest = 0;
    static int laravelAuthentication = 1;
    static int firebaseAuthentication = 2;

    static Map<String, dynamic> dummy = {
        "name": "Guest",
        "email": "Please login",
        "type": 0,
    };

    UserState() : super(dummy);

    void saveUser(Map<String, dynamic> info) {
        emit(info);
    }

    void removeUser() {
        emit(dummy);
    }
}
