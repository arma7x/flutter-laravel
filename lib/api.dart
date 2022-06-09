import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laravel/bloc/AuthState.dart';
import 'package:flutter_laravel/bloc/UserState.dart';

class Api {

    static const String tokenKey = "sanctum-token";
    static const String userKey = "laravel-user";
    static const String baseUrl = '192.168.43.33:8000'; // 192.168.43.33:8000 192.168.56.1:8000
    static const String pingPath = 'api/ping';
    static const String createTokenPath = 'api/tokens/create';
    static const String userInfoPath = 'api/user';
    static const String registerPath = 'register';
    static const String resetPasswordPath = 'password/reset';

    static Future<http.Response> pingServer() async {
        final url = Uri.http(baseUrl, pingPath);
        return await http.get(url);
    }

    static void createToken(Map<String, String> parameter, Function(String) errorCallback, Function() successCallback, BuildContext context) async {
        try {
            final url = Uri.http(baseUrl, createTokenPath);
            final authResponse = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'user-Agent': 'Flutter',
                },
                body: json.encode(parameter),
            );
            final authResponseBody = json.decode(authResponse.body);
            if (authResponse.statusCode == 200) {
                final userResponse = await getUserInfo(authResponseBody['token']);
                final userResponseBody = json.decode(userResponse.body);
                if (userResponse.statusCode == 200) {
                    saveSession(authResponseBody['token'], userResponseBody, context);
                    successCallback();
                } else if (userResponse.statusCode == 401) {
                    if (userResponseBody['message'] != null) {
                        errorCallback(userResponseBody['message']);
                    } else {
                        errorCallback("Unknown Error: 4");
                    }
                } else {
                    errorCallback("Unknown Error: 3");
                }
            } else if (authResponse.statusCode == 422) {
                // authResponseBody['errors']
                if (authResponseBody['message'] != null) {
                    errorCallback(authResponseBody['message']);
                } else {
                    errorCallback("Unknown Error: 2");
                }
            } else if (authResponse.statusCode == 400) {
                if (authResponseBody['message'] != null) {
                    errorCallback(authResponseBody['message']);
                } else {
                    errorCallback("Unknown Error: 1");
                }
            } else {
                errorCallback("Unknown Error: 0");
            }
        } on SocketException {
            errorCallback("No Internet connection 😑");
        } on HttpException {
            errorCallback("Couldn't find the post 😱");
        } on FormatException {
            errorCallback("Bad response format 👎");
        }
    }

    static Future<http.Response> getUserInfo(String token) async {
        final url = Uri.http(baseUrl, userInfoPath);
        return await http.get(
            url,
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
            }
        );
    }

    static Uri getRegisterLink() {
        return Uri.http(baseUrl, registerPath);
    }

    static Uri getResetPasswordLink() {
        return Uri.http(baseUrl, resetPasswordPath);
    }

    static IOSOptions _getIOSOptions() {
        return const IOSOptions(accountName: "flutter-laravel");
    }

    static AndroidOptions _getAndroidOptions() {
        return const AndroidOptions(encryptedSharedPreferences: true);
    }

    static void validateToken(String? qrtoken, Function(String) errorCallback, Function() successCallback, BuildContext context) async {

        void fallback(String token, String? usr) {
            if (usr != null) {
                final decodedUser = json.decode(usr);
                saveSession(token, decodedUser, context);
            }
        }

        const storage = FlutterSecureStorage();
        String? token = qrtoken;
        if (token == null)
            token = await storage.read(key: tokenKey);
        if (token != null) {
            String? user = await storage.read(key: userKey);
            try {
                final response = await getUserInfo(token);
                final responseBody = json.decode(response.body);
                if (response.statusCode == 200) {
                    saveSession(token, responseBody, context);
                    successCallback();
                } else if (response.statusCode == 401) {
                    errorCallback(responseBody['message']!);
                    destroySession(context);
                } else {
                    errorCallback("Unknown");
                    fallback(token, user);
                }
            } on SocketException {
                errorCallback("No Internet connection 😑");
                fallback(token, user);
            } on HttpException {
                errorCallback("Couldn't find the post 😱");
                fallback(token, user);
            } on FormatException {
                errorCallback("Bad response format 👎");
                fallback(token, user);
            }
        }
    }

    static void saveSession(String token, Map<String, dynamic> user, BuildContext context) async {
        const storage = FlutterSecureStorage();
        await storage.write(
            key: tokenKey,
            value: token,
            iOptions: _getIOSOptions(),
            aOptions: _getAndroidOptions(),
        );
        BlocProvider.of<AuthState>(context).add(UserLoggedIn());
        await storage.write(
            key: userKey,
            value: json.encode(user),
            iOptions: _getIOSOptions(),
            aOptions: _getAndroidOptions(),
        );
        BlocProvider.of<UserState>(context).saveUser(user);
    }

    static void destroySession(BuildContext context) async {
        const storage = FlutterSecureStorage();
        await storage.delete(
            key: tokenKey,
            iOptions: _getIOSOptions(),
            aOptions: _getAndroidOptions(),
        );
        BlocProvider.of<AuthState>(context).add(UserLoggedOut());
        await storage.delete(
            key: userKey,
            iOptions: _getIOSOptions(),
            aOptions: _getAndroidOptions(),
        );
        BlocProvider.of<UserState>(context).removeUser();
    }

}
