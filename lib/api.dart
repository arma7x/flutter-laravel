import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laravel/bloc/AuthState.dart';
import 'package:flutter_laravel/bloc/UserState.dart';

class Api {

    static const String tokenKey = "sanctum-token";
    static const String userKey = "laravel-user";
    static const String baseUrl = '192.168.56.1:8000';
    static const String pingPath = 'api/pingPath';
    static const String createTokenPath = 'api/tokens/create';
    static const String userInfoPath = 'api/user';
    static const String registerPath = 'registerPath';
    static const String resetPasswordPath = 'password/reset';

    static Future<http.Response> pingServer() async {
        final url = Uri.http(baseUrl, pingPath);
        return await http.get(url);
    }

    static Future<http.Response> createToken(Map<String, String> parameter) async {
        final url = Uri.http(baseUrl, createTokenPath);
        return await http.post(
            url,
            headers: <String, String>{
                'Authorization': 'application/json; charset=UTF-8',
            },
            body: json.encode(parameter),
        );
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

    static String getRegisterLink() {
        return Uri.http(baseUrl, registerPath).toString();
    }

    static String getResetPasswordLink() {
        return Uri.http(baseUrl, resetPasswordPath).toString();
    }

    static IOSOptions _getIOSOptions() {
        return const IOSOptions(accountName: "flutter-laravel");
    }

    static AndroidOptions _getAndroidOptions() {
        return const AndroidOptions(encryptedSharedPreferences: true);
    }

    static void validateToken(BuildContext context) async {
        const storage = FlutterSecureStorage();
        String? token = await storage.read(key: tokenKey); // '78|EyFHNquvDBLxsD7GS9YudY5nfhJyKBMuFMIfBKcb';
        // Map<String, dynamic> userMap = json.decode(user!);
        if (token != null) {
            String? user = await storage.read(key: userKey);
            try {
                final response = await getUserInfo(token);
                print(response.body);
                final responseBody = json.decode(response.body);
                if (response.statusCode == 200) {
                    print(responseBody); // save
                } else if (response.statusCode == 401) {
                    final snackBar = SnackBar(content: Text(responseBody['message']!));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    destroySession(context);
                } else {
                    final snackBar = SnackBar(content: Text("Unknown"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
            } on SocketException {
                final snackBar = SnackBar(content: Text("No Internet connection 😑"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } on HttpException {
                final snackBar = SnackBar(content: Text("Couldn't find the post 😱"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } on FormatException {
                final snackBar = SnackBar(content: Text("Bad response format 👎"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
        } else {
            print("Please login");
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
