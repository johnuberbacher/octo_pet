import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
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
  String petIndex = '0';
  String petDob = '';
  int petLevel = 1;
  int petHunger = 100;
  int petHappiness = 100;
  int petHealth = 100;
  String petMood = '';
  String petHistory = '';
  final eggSprites = ['assets/images/egg1.png', 'assets/images/egg2.png'];
  final petFoxSprites = ['assets/images/pet1_layer1.png', 'assets/images/pet1_layer2.png'];
  final petBatSprites = ['assets/images/pet2_layer1.png', 'assets/images/pet2_layer2.png'];
  final petDogSprites = ['assets/images/pet3_layer1.png', 'assets/images/pet3_layer2.png'];
  final wasteSprites = ['assets/images/waste1.png', 'assets/images/waste2.png'];
  final fruitSprites = [
    'assets/images/fruit1.png',
    'assets/images/fruit2.png',
    'assets/images/fruit3.png',
    'assets/images/fruit4.png',
  ];
  String hatchMsg = 'Hatch me!';
  int hatchCount = 0;
  bool showMenu = false;
  bool eating = false;
  bool waste = false;

  int gameTicker = 0;
  int gameTickerDuration = 1000;
  Audio audioUI = Audio.load('assets/sfx/ui.wav');
  Audio audioClean = Audio.load('assets/sfx/clean.wav');
  Audio audioHatch = Audio.load('assets/sfx/hatch.wav');
  Audio audioSpawn = Audio.load('assets/sfx/spawn.wav');
  Audio audioFull = Audio.load('assets/sfx/full.wav');
  Audio audioPoof = Audio.load('assets/sfx/poof.wav');

  @override
  void initState() {
    super.initState();

    loadData();
    gameLoop();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        loadData();
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
    if (storage.getItem('petType') == 'octo-egg' || storage.getItem('petType') == null) {
      storage.setItem('petType', 'octo-egg');
    } else {
      print("Local sotrage data has been found, loading now...");
      loadLocalStorage();
      print("Local data has been loaded!");
    }
  }

  void saveLocalStorage() async {
    await storage.ready;
    storage.setItem('petHunger', petHunger);
    storage.setItem('petHappiness', petHappiness);
    storage.setItem('petHealth', petHealth);
    storage.setItem('petLevel', petLevel);
  }

  void loadLocalStorage() async {
    await storage.ready;
    setState(() {
      petType = storage.getItem('petType');
      petIndex = storage.getItem('petIndex');
      petDob = storage.getItem('petDob');
      petHunger = storage.getItem('petHunger');
      petHappiness = storage.getItem('petHappiness');
      petHealth = storage.getItem('petHealth');
      petLevel = storage.getItem('petLevel');
      petHistory = storage.getItem('petHistory');
    });
  }

  void poof() async {
    audioPoof.play();
    await storage.ready;
    String currentPetHistory = storage.getItem('petHistory');
    String updatedPetHistory = currentPetHistory + '${petType}:${petIndex.toString()}:${petDob}, ';
    storage.setItem('petHistory', updatedPetHistory);
    petType = 'octo-egg';
    petIndex = '0';
    petDob = '';
    petLevel = 1;
    petHunger = 100;
    petHappiness = 100;
    petHealth = 100;
    petMood = '';
    showMenu = false;
    eating = false;
    waste = false;
  }

  void gameLoop() {
    // Game Loop
    Timer.periodic(Duration(milliseconds: gameTickerDuration), (timer) {
      setState(() => gameTicker++);
      int incrementModifier = 1;
      int positiveModifier = 2;
      int minimumModifier = 0;
      int maximumModifier = 75;

      if (petType != 'octo-egg') {
        // Hunger Loop
        if (petHunger > minimumModifier) {
          setState(() {
            petHunger -= incrementModifier;
            print('petHunger: ${petHunger}');
          });
        }
        // Waste Loop
        if (waste == false) {
          if (petHunger <= 25) {
            int randomWasteEncounter = (Random().nextInt(100) + 1);
            if (randomWasteEncounter <= 15) {
              print("Waste Value: ");
              print(randomWasteEncounter);
              setState(() {
                waste = true;
              });
            }
          }
        }
        // Happiness Loop
        if (petHunger == minimumModifier && petHappiness > minimumModifier) {
          setState(() {
            petHappiness -= incrementModifier;
            print('petHappiness: ${petHappiness}');
          });
        }
        if (petHunger >= maximumModifier && petHappiness <= maximumModifier) {
          petHappiness += positiveModifier;
        }
        // Health Loop
        if (petHunger == minimumModifier &&
            petHappiness == minimumModifier &&
            petHealth > minimumModifier) {
          setState(() {
            petHealth -= incrementModifier;
            print('petHealth: ${petHealth}');
          });
        } else if (petHunger >= maximumModifier &&
            petHappiness >= maximumModifier &&
            petHealth < 100) {
          setState(() {
            petHealth += positiveModifier;
          });
        }

        if (petHealth == minimumModifier) {
          // Poof!!!
          print('poof! :(');
          poof();
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

  actionHatchEgg() async {
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
        int randomPetIndex = Random().nextInt(900000) + 100000;
        int randomPetType = (Random().nextInt(100) + 1);
        String petDateOfBirth =
            DateTime.now().toString().substring(0, 10).replaceAll(RegExp(r'[^\w\s]+'), '/');
        String newPetType = '';
        if (randomPetType <= 33) {
          newPetType = 'octo-fox';
        } else if (randomPetType >= 34 && randomPetType <= 66) {
          newPetType = 'octo-bat';
        } else if (randomPetType >= 67) {
          newPetType = 'octo-dog';
        }
        print("No saved data found, creating now...");
        await storage.ready;
        storage.setItem('petIndex', randomPetIndex.toString());
        storage.setItem(
          'petDob',
          petDateOfBirth,
        );
        storage.setItem('petHunger', 100);
        storage.setItem('petHappiness', 100);
        storage.setItem('petHealth', 100);
        storage.setItem('petLevel', 1);

        if (storage.getItem('petHistory') == null) {
          storage.setItem('petHistory', '');
          print('NO NO NO pet history found:');
          print(storage.getItem('petHistory'));
        } else {
          print('YES YES YES pet history found:');
          print(storage.getItem('petHistory'));
        }
        print("New Egg has been saved to local storage!");
        print("History: ${newPetType},${randomPetIndex.toString()},${petDateOfBirth},");
        storage.setItem('petType', newPetType);
        loadLocalStorage();
        hatchCount = 0;
        audioSpawn.play();
      }
    }
  }

  actionCheckEmotion() {
    print("Here");
    int emotionCount = 0;
    setState(() {
      emotionCount++;
    });
  }

  actionCleanWaste() {
    setState(() {
      audioClean.play();
      petHappiness += 5;
      waste = false;
    });
  }

  actionHideMenu() {
    print(petHistory);
    setState(() {
      audioUI.play();
      showMenu = !showMenu;
    });
  }

  actionFeed() async {
    if (eating == false && petType != 'octo-egg') {
      setState(() {
        audioUI.play();
        eating = true;
        Future.delayed(const Duration(milliseconds: 2000)).then((_) {
          petHunger = 100;
          audioFull.play();
          eating = false;
        });
      });
    }
  }

  actionPlay() {
    setState(() {
      petHappiness = 100;
    });
  }

  showPet() {
    if (petType == 'octo-fox') {
      return Image.asset(
        petFoxSprites[gameTicker % petFoxSprites.length],
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      );
    } else if (petType == 'octo-bat') {
      return Image.asset(
        petBatSprites[gameTicker % petBatSprites.length],
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      );
    } else if (petType == 'octo-dog') {
      return Image.asset(
        petDogSprites[gameTicker % petDogSprites.length],
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      );
    } else {
      return Image.asset(
        eggSprites[gameTicker % eggSprites.length],
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      );
    }
  }

  showWaste() {
    if (waste == true && petType != 'octo-egg') {
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
    if (eating == true && petType != 'octo-egg') {
      return Positioned(
        bottom: 0,
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.4,
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
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  actionCheckEmotion();
                                },
                                child: Flex(
                                  direction: Axis.vertical,
                                  children: [
                                    Expanded(
                                      child: petType == 'octo-egg'
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width * 0.4,
                                                  child: AnimatedSwitcher(
                                                    duration:
                                                        Duration(milliseconds: gameTickerDuration),
                                                    child: Image.asset(
                                                      eggSprites[gameTicker % eggSprites.length],
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
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                clipBehavior: Clip.none,
                                                children: [
                                                  AnimatedSwitcher(
                                                    duration:
                                                        Duration(milliseconds: gameTickerDuration),
                                                    child: showPet(),
                                                  ),
                                                  petEmote(petMood),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            showWaste(),
                            showFood(),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
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
                                          "History",
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
                  showMenu
                      ? MenuWidget(
                          hideMenu: actionHideMenu, showMenu: showMenu, petHistory: petHistory)
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
