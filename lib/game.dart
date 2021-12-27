import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/ui.dart';
import 'package:octo_pet/menu.dart';
import 'package:audiofileplayer/audiofileplayer.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  double petHunger = 1.0;
  double petHappiness = 1.0;
  double petHealth = 1.0;
  final petSprites = [
    'assets/images/pet1_layer1.png',
    'assets/images/pet1_layer2.png'
  ];
  final wasteSprites = ['assets/images/waste1.png', 'assets/images/waste2.png'];
  final fruitSprites = [
    'assets/images/fruit1.png',
    'assets/images/fruit2.png',
    'assets/images/fruit3.png',
    'assets/images/fruit4.png',
  ];
  bool showWaste = false;
  bool showStats = false;

  bool eating = false;

  int gameTicker = 0;
  int gameTickerDuration = 1000;
  Audio audioUI = Audio.load('assets/sfx/ui.wav');

  @override
  void initState() {
    super.initState();
    gameLoop();
  }

  void gameLoop() {
    // Game Loop
    Timer.periodic(Duration(milliseconds: gameTickerDuration), (timer) {
      setState(() => gameTicker++);
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
          gameTickerDuration = 500;
        });
      } else if (petHunger > maximumModifier &&
          petHappiness > maximumModifier &&
          petHealth < 1.0) {
        setState(() {
          petHealth += positiveModifier;
          gameTickerDuration = 500;
        });
      }
    });
  }

  actionCheckEmotion() async {
    int emotionCount = 0;
    setState(() {
      emotionCount++;
    });
  }

  actionHideMenu() {
    setState(() {
      audioUI.play();
      showStats = !showStats;
    });
  }

  actionFeed() async {
    setState(() {
      eating = true;
      audioUI.play();
      Future.delayed(const Duration(milliseconds: 3000)).then((_) {
        eating = false;
        petHunger = 1.0;
      });
    });
  }

  actionCleanWaste() {
    setState(() {});
  }

  actionPlay() {
    setState(() {
      petHappiness = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58734a),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            repeat: ImageRepeat.repeat,
            alignment: Alignment(0, 7),
            image: AssetImage('assets/images/bg.png'),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
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
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: AnimatedSwitcher(
                                          duration: Duration(
                                              milliseconds: gameTickerDuration),
                                          child: Image.asset(
                                            petSprites[
                                                gameTicker % petSprites.length],
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -MediaQuery.of(context).size.width * 0.33,
                                left: MediaQuery.of(context).size.width * 0.3,
                                right: MediaQuery.of(context).size.width * 0.3,
                                child: petHealth < 0.5
                                    ? SizedBox(
                                        child: Image.asset(
                                          'assets/images/emote_hungry.png',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )
                                    : Container(),
                              ),
                              Positioned(
                                bottom:
                                    -MediaQuery.of(context).size.width * 0.4,
                                child: petHunger < 0.5
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: GestureDetector(
                                          onTap: actionCleanWaste(),
                                          child: AnimatedSwitcher(
                                            duration: Duration(
                                                milliseconds:
                                                    gameTickerDuration),
                                            child: Image.asset(
                                              wasteSprites[gameTicker %
                                                  wasteSprites.length],
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                              eating
                                  ? Positioned(
                                      bottom:
                                          -MediaQuery.of(context).size.width *
                                              0.33,
                                      left: MediaQuery.of(context).size.width *
                                          0.3,
                                      right: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: SizedBox(
                                        child: AnimatedSwitcher(
                                          duration:
                                              Duration(milliseconds: 1000),
                                          child: Image.asset(
                                            fruitSprites[gameTicker %
                                                fruitSprites.length],
                                            fit: BoxFit.fitWidth,
                                            gaplessPlayback: true,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
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
                            onPressed: () {
                              actionHideMenu();
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Menu",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              showStats
                  ? MenuWidget(hideMenu: actionHideMenu, showStats: showStats)
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
