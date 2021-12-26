import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/ui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent, // Button color
            onPrimary: Color(0xFF222222),
            padding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            textStyle: TextStyle(
              fontFamily: 'EarlyGameboy',
              fontSize: 18.0,
            ),
            side: BorderSide(
              width: 6.0,
              color: Color(0xFF222222),
            ),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Color(0xFF222222),
              fontFamily: 'EarlyGameboy',
              displayColor: Color(0xFF222222),
            ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool petLove = false;
  double petHunger = 1.0;
  double petHappiness = 1.0;
  double petHealth = 1.0;
  final petSprites = [
    'https://i.imgur.com/eR1dsFg.png',
    'https://i.imgur.com/EcdT7CY.png'
  ];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    gameLoop();
  }

  void gameLoop() {
    // Pet Animation Loop
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _index++);
    });
    // Hunger Loop
    Timer.periodic(const Duration(seconds: 1), (timer) {
      double incrementModifier = 0.1;
      double positiveModifier = 0.2;
      double minimumModifier = 0.15;
      double maximumModifier = 0.75;
      // Hunger Loop
      if (petHunger > minimumModifier) {
        setState(() {
          petHunger -= incrementModifier;
        });
      }
      // Happiness Loop
      if (petHunger < minimumModifier && petHappiness > minimumModifier) {
        setState(() {
          petHappiness -= incrementModifier;
        });
      } else if (petHunger > maximumModifier) {
        petHappiness += positiveModifier;
      }
      // Health Loop
      if (petHunger < minimumModifier &&
          petHappiness < minimumModifier &&
          petHealth > minimumModifier) {
        setState(() {
          petHealth -= incrementModifier;
        });
      } else if (petHunger > maximumModifier &&
          petHappiness > maximumModifier &&
          petHealth < 1.0) {
        setState(() {
          petHealth += positiveModifier;
        });
      }
    });
    // Health Loop
  }

  actionFeed() {
    setState(() {
      petHunger = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF58734a),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            repeat: ImageRepeat.repeat,
            alignment: Alignment(0, 7),
            image: NetworkImage("https://i.imgur.com/9cXaDb2.png"),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              UserInterfaceWidget(
                petHunger: petHunger,
                petHappiness: petHappiness,
                petHealth: petHealth,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () => {},
                            child: Stack(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: Image.network(
                                      petSprites[_index % petSprites.length],
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -240,
                            left: 0,
                            right: 0,
                            child: petHealth < 0.5
                                ? Image.network(
                                    'https://i.imgur.com/eS0gpmW.png')
                                : Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Color(0xFF59734a).withOpacity(0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          actionFeed();
                        },
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Feed",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Play",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Stats",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
