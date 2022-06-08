import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_laravel/bloc/AuthState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    static void ValidateToken(BuildContext context) async {
        final _storage = const FlutterSecureStorage();
        String? token = await _storage.read(key: "sanctum-token");
        if (token != null) {
            print('ValidateToken: ${token}');
            SaveToken(token, context);
            // GetUserInfo(token);
            // if connectionless > retrieve UserInfoState from cache
            // if 401 > RemoveToken(context) && UserInfoState from cache
            // else > update UserInfoState cached
        } else {
            print('ValidateToken bad');
            RemoveToken(context);
        }
    }

    static void SaveToken(String token, BuildContext context) async {
        try {
            final _storage = const FlutterSecureStorage();
            await _storage.write(
                key: "sanctum-token",
                value: token,
                iOptions: const IOSOptions(accountName: "flutter-laravel"),
                aOptions: const AndroidOptions(encryptedSharedPreferences: true),
            );
            BlocProvider.of<AuthState>(context).add(UserLoggedIn());
            String? value = await _storage.read(key: "sanctum-token");
            // return Future<bool>.value(true);
        } catch(e) {
            RemoveToken(context);
            // return Future<bool>.value(false);
        }
    }

    static void RemoveToken(BuildContext context) async {
        final _storage = const FlutterSecureStorage();
        await _storage.delete(
            key: "sanctum-token",
            iOptions: const IOSOptions(accountName: "flutter-laravel"),
            aOptions: const AndroidOptions(encryptedSharedPreferences: true),
        );
        BlocProvider.of<AuthState>(context).add(UserLoggedOut());
    }

    // save token from secure storage
    static SaveUserInfo(Map<String, dynamic> info) {}

    // remove token from secure storage
    static RemoveUserInfo() {}

}
