import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/components/ui.dart';
import 'package:octo_pet/components/menu.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:localstorage/localstorage.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  final LocalStorage storage = LocalStorage('petData.json');
  String petType = 'octo-egg';
  String petDob = '';
  double petHunger = 0.1;
  double petHappiness = 1.0;
  double petHealth = 1.0;
  String petMood = '';
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
  Audio audioHatch = Audio.load('assets/sfx/hatch.wav');
  Audio audioSpawn = Audio.load('assets/sfx/spawn.wav');
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
        saveLocalStorage();
        print('saved to local storage');
        break;
      case AppLifecycleState.inactive:
        saveLocalStorage();
        print('saved to local storage');
        break;
      case AppLifecycleState.paused:
        saveLocalStorage();
        print('saved to local storage');
        break;
      case AppLifecycleState.detached:
        saveLocalStorage();
        print('saved to local storage');
        break;
    }
  }

  void loadData() async {
    await storage.ready;
    // If you have an egg or are a new player
    if (storage.getItem('petType') == 'octo-egg' ||
        storage.getItem('petType') == null) {
      storage.setItem('petType', 'octo-egg');
      storage.setItem(
        'petDob',
        DateTime.now()
            .toString()
            .substring(0, 10)
            .replaceAll(RegExp(r'[^\w\s]+'), '/'),
      );
      storage.setItem('petHunger', 1.0);
      storage.setItem('petHappiness', 1.0);
      storage.setItem('petHealth', 1.0);
      storage.setItem('petLevel', 0);
      print("NO storage found");
      await storage.ready;
      petType = storage.getItem('petType');
      petDob = storage.getItem('petDob');
      petHunger = storage.getItem('petHunger');
      petHappiness = storage.getItem('petHappiness');
      petHealth = storage.getItem('petHealth');
      petLevel = storage.getItem('petLevel');
      print("Saved new data to local storage");
    } else {
      print("Previous Local storage found");
      await storage.ready;
      petType = storage.getItem('petType');
      petDob = storage.getItem('petDob');
      petHunger = storage.getItem('petHunger');
      petHappiness = storage.getItem('petHappiness');
      petHealth = storage.getItem('petHealth');
      petLevel = storage.getItem('petLevel');
      print("Loading local storage to app data");
    }
  }

  void saveLocalStorage() async {
    await storage.ready;
    storage.setItem('petType', petType);
    storage.setItem(
      'petDob',
      petDob,
    );
    storage.setItem('petHunger', petHunger);
    storage.setItem('petHappiness', petHappiness);
    storage.setItem('petHealth', petHealth);
    storage.setItem('petLevel', petLevel);
  }

  void gameLoop() {
    // Game Loop
    Timer.periodic(Duration(milliseconds: gameTickerDuration), (timer) {
      setState(() => gameTicker++);
      double incrementModifier = 0.025;
      double positiveModifier = 0.05;
      double minimumModifier = 0.15;
      double maximumModifier = 0.75;

      if (petType != 'octo-egg') {
        // Hunger Loop
        if (petHunger > minimumModifier) {
          setState(() {
            petHunger -= incrementModifier;
          });
        }
        // Waste Loop
        if (waste == false) {
          if (petHunger <= 0.5) {
            int randomWasteEncounter = (Random().nextInt(10) + 1);
            if (randomWasteEncounter <= 5) {
              print("Waste Value: ");
              print(randomWasteEncounter);
              setState(() {
                waste = true;
              });
            }
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
        int randomEncounter = (Random().nextInt(2000) + 1);
        if (randomEncounter <= 5) {
          setState(() {
            itemActive = true;
          });
        }

        // Mood Loop
        if (petHunger <= minimumModifier) {
          setState(() {
            petMood == 'hungry';
          });
        } else {
          setState(() {
            petMood == '';
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
          audioHatch.play();
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
          audioSpawn.play();
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
        Future.delayed(const Duration(milliseconds: 2000)).then((_) {
          petHunger = 1.0;
          audioFull.play();
          eating = false;
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
      return Positioned(
        bottom: 0,
        left: 0,
        // left: -MediaQuery.of(context).size.width * 0.25,
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          child: InkWell(
            onTap: () {
              actionCleanWaste();
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: gameTickerDuration),
              child: Image.asset(
                wasteSprites[gameTicker % wasteSprites.length],
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        child: Container(),
      );
    }
  }

  showItem() {
    if (itemActive == true) {
      return Positioned(
        bottom: 0,
        right: 0,
        child: InkWell(
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
        ),
      );
    } else {
      return Positioned(
        child: Container(),
      );
    }
  }

  petEmote(String petMood) {
    if (petMood != '') {
      return Positioned(
        bottom: MediaQuery.of(context).size.width * 0.35,
        left: 0,
        right: 0,
        child: Image.asset(
          'assets/images/emote_$petMood.png',
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return Positioned(
        bottom: MediaQuery.of(context).size.width * 0.35,
        left: 0,
        right: 0,
        child: Container(),
      );
    }
  }

  showFood() {
    if (eating == true) {
      return Positioned(
        bottom: 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: gameTickerDuration),
            child: Image.asset(
              fruitSprites[gameTicker % fruitSprites.length],
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      );
    } else {
      return Positioned(child: Container());
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
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 400.0,
                maxWidth: 500.0,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
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
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  actionCheckEmotion();
                                },
                                child: Flex(
                                  direction: Axis.vertical,
                                  children: [
                                    Expanded(
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
                                              child: Stack(
                                                alignment: Alignment.center,
                                                clipBehavior: Clip.none,
                                                children: [
                                                  AnimatedSwitcher(
                                                    duration: Duration(
                                                        milliseconds:
                                                            gameTickerDuration),
                                                    child: Image.asset(
                                                      petSprites[gameTicker %
                                                          petSprites.length],
                                                      fit: BoxFit.fitWidth,
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                                  ),
                                                  petEmote(petMood),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                )),
                            showWaste(),
                            showItem(),
                            showFood(),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: petType != 'octo-egg'
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                      ? MenuWidget(
                          hideMenu: actionHideMenu, showStats: showStats)
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
