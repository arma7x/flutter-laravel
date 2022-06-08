import 'package:flutter_bloc/flutter_bloc.dart';

class UserState extends Cubit<Map<String, dynamic>> {
    UserState() : super(<String, dynamic>{
        "name": "Guest",
        "email": "Please login",
    });

    void setUser(Map<String, dynamic> info) {
        emit(info);
    }

    void resetUser() {
        emit(<String, dynamic>{
            "name": "Guest",
            "email": "Please login",
        });
    }
}
