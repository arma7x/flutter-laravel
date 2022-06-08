import 'package:flutter_bloc/flutter_bloc.dart';

class UserState extends Cubit<Map<String, dynamic>> {
    UserState() : super(<String, dynamic>{
        "name": "Guest",
        "email": "Please login",
    });

    void saveUser(Map<String, dynamic> info) {
        emit(info);
    }

    void removeUser() {
        emit(<String, dynamic>{
            "name": "Guest",
            "email": "Please login",
        });
    }
}
