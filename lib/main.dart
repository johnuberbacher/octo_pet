import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/game.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF58734a),
          secondary: const Color(0xFF222222),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            enableFeedback: false,
            primary: const Color(0xFF58734a), // Button color
            onPrimary: const Color(0xFF222222),
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 14.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            textStyle: const TextStyle(
              fontFamily: 'EarlyGameboy',
              fontSize: 15.0,
            ),
            side: const BorderSide(
              width: 6.0,
              color: Color(0xFF222222),
            ),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF222222),
              fontFamily: 'EarlyGameboy',
              displayColor: const Color(0xFF222222),
            ),
      ),
      home: const Game(),
    );
  }
}
