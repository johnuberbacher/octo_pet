import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/ui.dart';
import 'package:audiofileplayer/audiofileplayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            enableFeedback: false,
            primary: Colors.transparent, // Button color
            onPrimary: const Color(0xFF222222),
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            textStyle: const TextStyle(
              fontFamily: 'EarlyGameboy',
              fontSize: 18.0,
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double petHunger = 1.0;
  double petHappiness = 1.0;
  double petHealth = 1.0;
  final petSprites = [
    'assets/images/pet1layer1.png',
    'assets/images/pet1layer2.png'
  ];
  final wasteSprites = ['assets/images/waste1.png', 'assets/images/waste2.png'];
  bool showWaste = false;
  int _index = 0;
  Audio audioUI = Audio.load('assets/sfx/ui.wav');

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
    // Game Loop
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

  actionFeed() async {
    setState(() {
      audioUI.play();
      petHunger = 1.0;
    });
  }

  actionPlay() {
    setState(() {
      petHappiness = 1.0;
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
            image: AssetImage('assets/images/bg.png'),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () => {},
                            child: Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      child: Image.asset(
                                        petSprites[_index % petSprites.length],
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -MediaQuery.of(context).size.width * 0.675,
                            left: 0,
                            right: 0,
                            child: petHealth < 0.5
                                ? Image.asset('assets/images/hungry.png')
                                : Container(),
                          ),
                          Positioned(
                            bottom: -MediaQuery.of(context).size.width * 0.4,
                            left: 0,
                            child: petHunger < 0.5
                                ? Image.asset(
                                    wasteSprites[_index % wasteSprites.length],
                                    fit: BoxFit.fitWidth,
                                  )
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
                        onPressed: () {
                          actionPlay();
                        },
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
                            "Items",
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
