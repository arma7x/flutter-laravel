import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoState extends Cubit<Map<String, dynamic>> {
    UserInfoState() : super(<String, dynamic>{});

    void setUserInfo(Map<String, dynamic> info) {
        emit(info);
    }
}
