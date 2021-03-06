import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    static const String registerPath = 'register';
    static const String resetPasswordPath = 'password/reset';
    static const String apiUserPath = 'api/user';
    static const String apiFirebaseUserPath = 'api/firebase/user';

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
                },
                body: json.encode(parameter),
            );
            final authResponseBody = json.decode(authResponse.body);
            if (authResponse.statusCode == 200) {
                final userResponse = await getUser(authResponseBody['token']);
                final userResponseBody = json.decode(userResponse.body);
                if (userResponse.statusCode == 200) {
                    userResponseBody['type'] = UserState.laravel;
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
            errorCallback("No Internet connection ????");
        } on HttpException {
            errorCallback("Couldn't find the post ????");
        } on FormatException {
            errorCallback("Bad response format ????");
        }
    }

    static Future<http.Response> getUser(String token) async {
        final url = Uri.http(baseUrl, apiUserPath);
        return await http.get(
            url,
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
            }
        );
    }

    static Future<http.Response> getFirebaseUser(String token) async {
        final url = Uri.http(baseUrl, apiFirebaseUserPath);
        return await http.get(
            url,
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': token,
            }
        );
    }

    static Uri getRegisterLink() {
        return Uri.http(baseUrl, registerPath);
    }

    static Uri getResetPasswordLink() {
        return Uri.http(baseUrl, resetPasswordPath);
    }

    static void validateToken(String? qrtoken, Function(String) errorCallback, Function() successCallback, BuildContext context) async {

        void fallback(String token, String? usr) {
            if (usr != null) {
                final decodedUser = json.decode(usr);
                if (decodedUser['type'] != UserState.firebase) {
                    decodedUser['type'] = UserState.laravel;
                    saveSession(token, decodedUser, context);
                }
            }
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = qrtoken;
        if (token == null)
            token = prefs.getString(tokenKey);
        if (token != null) {
            String? user = prefs.getString(userKey);
            try {
                final response = await getUser(token);
                final responseBody = json.decode(response.body);
                if (response.statusCode == 200) {
                    responseBody['type'] = UserState.laravel;
                    saveSession(token, responseBody, context);
                    successCallback();
                } else if (response.statusCode == 401) {
                    errorCallback(responseBody['message']!);
                    if (user != null) {
                        final decodedUser = json.decode(user);
                        if (decodedUser['type'] != UserState.firebase) {
                            destroySession(context);
                        }
                    }
                } else {
                    errorCallback("Unknown");
                    fallback(token, user);
                }
            } on SocketException {
                errorCallback("No Internet connection ????");
                fallback(token, user);
            } on HttpException {
                errorCallback("Couldn't find the post ????");
                fallback(token, user);
            } on FormatException {
                errorCallback("Bad response format ????");
                fallback(token, user);
            }
        }
    }

    static Future<String?> getToken() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        return prefs.getString(tokenKey);
    }

    static Future<Map<String, dynamic>> getSession() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? user = prefs.getString(userKey);
        if (user == null)
            return UserState.dummy;
        final decodedUser = json.decode(user);
        return decodedUser;
    }

    static void saveSession(String token, Map<String, dynamic> user, BuildContext context) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        BlocProvider.of<AuthState>(context).add(UserLoggedIn());
        await prefs.setString(userKey, json.encode(user));
        BlocProvider.of<UserState>(context).saveUser(user);
    }

    static void destroySession(BuildContext context) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await await prefs.remove(tokenKey);
        BlocProvider.of<AuthState>(context).add(UserLoggedOut());
        await await prefs.remove(userKey);
        BlocProvider.of<UserState>(context).removeUser();
    }

}
