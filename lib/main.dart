import 'package:flutter/material.dart';
import 'package:flutter_laravel/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laravel/bloc/AuthState.dart';

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
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Api.ValidateToken(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Laravel'),
    );
  }
}

class MyHomePage extends StatelessWidget {

  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  void _saveToken(ctx) {
    Api.SaveToken("Test", ctx);
  }

  void _removeToken(ctx) {
    Api.RemoveToken(ctx);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Your status is:',),
            Text(
              BlocProvider.of<AuthState>(context, listen: true).state.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _saveToken(context),
            tooltip: 'Save Token',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => _removeToken(context),
            tooltip: 'Remove Token',
            child: const Icon(Icons.remove),
          )
        ]
      ),
    );
  }
}
