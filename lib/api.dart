import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {

    static const String BASE_URL = '192.168.56.1:8000';
    static const String PING = 'api/ping';
    static const String CREATE_TOKEN = 'api/tokens/create';
    static const String USER_INFO = 'api/user';
    static const String LOGIN = 'login';
    static const String REGISTER = 'register';
    static const String RESET_PASSWORD = 'password/reset';

    static Future<http.Response> PingServer() async {
        final url = Uri.http(BASE_URL, PING);
        return await http.get(url);
    }

    static Future<http.Response> CreateToken(Map<String, String> parameter) async {
        final url = Uri.http(BASE_URL, CREATE_TOKEN);
        return await http.post(
            url,
            headers: <String, String>{
                'Authorization': 'application/json; charset=UTF-8',
            },
            body: json.encode(parameter),
        );
    }

    static Future<http.Response> GetUserInfo(String token) async {
        final url = Uri.http(BASE_URL, CREATE_TOKEN);
        return await http.get(
            url,
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${token}',
            }
        );
    }

    static String GetLoginLink() {
        return Uri.http(BASE_URL, LOGIN).toString();
    }

    static String GetRegisterLink() {
        return Uri.http(BASE_URL, REGISTER).toString();
    }

    static String GetResetPasswordLink() {
        return Uri.http(BASE_URL, RESET_PASSWORD).toString();
    }

    // save token to secure storage
    static String SaveToken(String token) {
        return token;
    }

    // save token from secure storage
    static SaveUserInfo(Map<String, String> info) {}

    // remove token from secure storage
    static RemoveUserInfo() {}

}
