import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/ui.dart';
import 'package:octo_pet/menu.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:localstorage/localstorage.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  final LocalStorage storage = LocalStorage('petData.json');
  String petType = 'octo-egg';
  String petDob = '';
  double petHunger = 1.0;
  double petHappiness = 1.0;
  double petHealth = 1.0;
  String hatchMsg = 'Hatch me!';
  int hatchCount = 0;
  int petLevel = 0;
  final eggSprites = ['assets/images/egg1.png', 'assets/images/egg2.png'];
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
  bool showStats = false;
  bool eating = false;
  bool waste = false;
  bool itemActive = false;

  int gameTicker = 0;
  int gameTickerDuration = 1000;
  Audio audioUI = Audio.load('assets/sfx/ui.wav');
  Audio audioClean = Audio.load('assets/sfx/clean.wav');
  Audio audioFull = Audio.load('assets/sfx/full.wav');

  @override
  void initState() {
    super.initState();
    loadData();
    gameLoop();
    // Add the observer.
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        print('saved to local storage');
        break;
      case AppLifecycleState.inactive:
        print('saved to local storage');
        break;
      case AppLifecycleState.paused:
        print('saved to local storage');
        break;
      case AppLifecycleState.detached:
        print('saved to local storage');
        break;
    }
  }

  void loadData() async {
    if (petType == 'octo-egg') {
      await storage.ready;
      storage.setItem('petType', 'octo-egg');
      storage.setItem(
        'petDob',
        DateTime.now()
            .toString()
            .substring(0, 10)
            .replaceAll(RegExp(r'[^\w\s]+'), '/'),
      );
      storage.setItem('petHunger', 0.5);
      storage.setItem('petHappiness', 0.5);
      storage.setItem('petHealth', 0.5);
      storage.setItem('petLevel', 0);
    }

    await storage.ready;
    petType = storage.getItem('petType');
    petDob = storage.getItem('petDob');
    petHunger = storage.getItem('petHunger');
    petHappiness = storage.getItem('petHappiness');
    petHealth = storage.getItem('petHealth');
    petHealth = storage.getItem('petLevel');
    print(petType);
    print(petDob);
    print(petHunger);
    print(petLevel);
  }

  void gameLoop() {
    // Game Loop
    Timer.periodic(Duration(milliseconds: gameTickerDuration), (timer) {
      setState(() => gameTicker++);
      double incrementModifier = 0.01;
      double positiveModifier = 0.02;
      double minimumModifier = 0.15;
      double maximumModifier = 0.75;

      if (petType != 'octo-egg') {
        // Hunger Loop
        if (petHunger > minimumModifier) {
          setState(() {
            petHunger -= incrementModifier;
            print(petHunger);
          });
        }
        // Waste Loop
        if (petHunger <= 0.5) {
          int randomWasteEncounter = (Random().nextInt(200) + 1);
          if (randomWasteEncounter <= 10) {
            print("Waste Value: ");
            print(randomWasteEncounter);
            setState(() {
              waste = true;
            });
          }
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

        // Item/Gift Loop
        int randomItemEncounter = (Random().nextInt(2000) + 1);
        if (randomItemEncounter <= 5) {
          print("////////////////////////");
          print("////////////////////////");
          print("Item Value: ");
          print(randomItemEncounter);
          print("////////////////////////");
          print("////////////////////////");
          setState(() {
            itemActive = true;
          });
        }
      }
    });
  }

  actionHatchEgg() {
    if (petType == 'octo-egg') {
      if (hatchCount < 3) {
        setState(() {
          hatchCount++;
          if (hatchCount == 0) {
            hatchMsg = 'Hatch me!';
          } else if (hatchCount == 1) {
            hatchMsg = 'Keep going!';
          } else if (hatchCount == 2) {
            hatchMsg = 'Almost there!';
          } else if (hatchCount == 3) {
            hatchMsg = 'Here I come!';
          }
        });
      } else if (hatchCount == 3) {
        setState(() {
          petType = 'octo-fox';
        });
      }
    }
  }

  actionCheckEmotion() async {
    print("Here");
    int emotionCount = 0;
    setState(() {
      emotionCount++;
    });
  }

  actionCollectItem() {
    setState(() {
      audioFull.play();
      itemActive = false;
    });
  }

  actionCleanWaste() {
    setState(() {
      audioClean.play();
      waste = false;
    });
  }

  actionHideMenu() {
    setState(() {
      audioUI.play();
      showStats = !showStats;
    });
  }

  actionFeed() async {
    if (eating == false) {
      setState(() {
        audioUI.play();
        eating = true;
        Future.delayed(const Duration(milliseconds: 3000)).then((_) {
          eating = false;
          petHunger = 1.0;
          audioFull.play();
        });
      });
    }
  }

  actionPlay() {
    setState(() {
      petHappiness = 1.0;
    });
  }

  showWaste() {
    if (waste == true) {
      return InkWell(
        onTap: () {
          actionCleanWaste();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: gameTickerDuration),
            child: Image.asset(
              wasteSprites[gameTicker % wasteSprites.length],
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  petEmote(String petMood) {
    return Positioned(
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
    );
  }

  showItem() {
    if (itemActive == true) {
      return InkWell(
        onTap: () {
          actionCollectItem();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: gameTickerDuration),
            child: Container(
              color: Colors.red,
              child: Image.asset(
                wasteSprites[gameTicker % wasteSprites.length],
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
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
                    petType: petType,
                    petDob: petDob,
                    petHunger: petHunger,
                    petHappiness: petHappiness,
                    petHealth: petHealth,
                    petLevel: petLevel,
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () {
                            actionCheckEmotion();
                          },
                          child: Stack(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: Center(
                                    child: petType == 'octo-egg'
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: AnimatedSwitcher(
                                                  duration: Duration(
                                                      milliseconds:
                                                          gameTickerDuration),
                                                  child: Image.asset(
                                                    eggSprites[gameTicker %
                                                        eggSprites.length],
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                hatchMsg,
                                                style: const TextStyle(
                                                  fontFamily: 'EarlyGameboy',
                                                  fontSize: 20.0,
                                                ),
                                              )
                                            ],
                                          )
                                        : SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            child: AnimatedSwitcher(
                                              duration: Duration(
                                                  milliseconds:
                                                      gameTickerDuration),
                                              child: Image.asset(
                                                petSprites[gameTicker %
                                                    petSprites.length],
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          )),
                              ),
                              petEmote('hungry'),
                              Positioned(
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
                                bottom: 0,
                                left: 0,
                                child: showWaste(),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: showItem(),
                              ),
                            ],
                          ),
                        ),
                        eating
                            ? Positioned(
                                bottom: 0,
                                left: MediaQuery.of(context).size.width * 0.3,
                                right: MediaQuery.of(context).size.width * 0.3,
                                child: SizedBox(
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 4000),
                                    child: Image.asset(
                                      fruitSprites[
                                          gameTicker % fruitSprites.length],
                                      fit: BoxFit.fitWidth,
                                      gaplessPlayback: true,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: petType != 'octo-egg'
                        ? Row(
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
                              const SizedBox(width: 5),
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
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    actionHatchEgg();
                                  },
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Hatch!",
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
