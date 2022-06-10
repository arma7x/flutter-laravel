import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_laravel/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laravel/bloc/AuthState.dart';
import 'package:flutter_laravel/bloc/UserState.dart';
import 'package:flutter_laravel/navigations/LoginScreen.dart';
import 'package:flutter_laravel/navigations/LoginQrCodeScreen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(const App()),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthState>(
          create: (BuildContext context) => AuthState(),
        ),
        BlocProvider<UserState>(
          create: (BuildContext context) => UserState(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter - Laravel Starter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter - Laravel Starter'),
    );
  }
}

class MyHomePage extends StatelessWidget {

  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  List<Widget> getDrawerMenu(bool status, BuildContext context) {
    if (!status) {
      return <Widget>[
        ListTile(
          title: const Text('Login'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        ListTile(
          title: const Text('Login via QR-Code'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const LoginQrCodeScreen()),
            );
          },
        ),
        ListTile(
          title: const Text('Register'),
          onTap: () async {
            Navigator.of(context).pop();
            try {
              await launchUrl(Api.getRegisterLink());
            } catch(e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
        ),
        ListTile(
          title: const Text('Forgot Password'),
          onTap: () async {
            Navigator.of(context).pop();
            try {
              await launchUrl(Api.getResetPasswordLink());
            } catch(e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
        ),
      ];
    }
    return <Widget>[
      ListTile(
        title: const Text('Logout'),
        onTap: () {
          Navigator.of(context).pop();
          Api.destroySession(context);
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {

    Api.validateToken(null, (String err) => {}, () => {}, context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: BlocBuilder<AuthState, bool>(
          builder: (context, bool status) {
            Map<String, dynamic> user = BlocProvider.of<UserState>(context, listen: true).state;
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 45.0,
                        backgroundColor: const Color(0xFF778899),
                        backgroundImage: NetworkImage("http://tineye.com/images/widgets/mona.jpg"),
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Hi ' + user['name']!.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15)
                      ),
                      SizedBox(height: 5),
                      Text(
                        user['email']!.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 13)
                      ),
                    ]
                  ),
                ),
                ...getDrawerMenu(status, context),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Your status is:'),
            BlocBuilder<AuthState, bool>(
              builder: (context, bool status) {
                return Text(
                  status.toString(),
                  style: Theme.of(context).textTheme.headline4,
                );
              }
            ),
          ],
        ),
      )
    );
  }
}
