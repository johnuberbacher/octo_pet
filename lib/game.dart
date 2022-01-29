import 'dart:async';
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
  DateTime petDob = DateTime.now();
  DateTime petPreviousDateTime = DateTime.now();
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
  final petBotSprites = ['assets/images/pet4_layer1.png', 'assets/images/pet4_layer2.png'];
  final petGhostSprites = ['assets/images/ghost_layer1.png', 'assets/images/ghost_layer2.png'];
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
  bool showEmote = false;

  int gameTicker = 0;
  int gameTickerDuration = 1000;
  Audio audioUI = Audio.load('assets/sfx/ui.wav');
  Audio audioClean = Audio.load('assets/sfx/clean.wav');
  Audio audioHatch = Audio.load('assets/sfx/hatch.wav');
  Audio audioSpawn = Audio.load('assets/sfx/spawn.wav');
  Audio audioFull = Audio.load('assets/sfx/full.wav');
  Audio audioPoof = Audio.load('assets/sfx/poof.wav');
  Audio audioEgg = Audio.load('assets/sfx/egg.wav');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    loadData();
    gameLoop();
  }

  @override
  void dispose() {
    saveLocalStorage();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        saveLocalStorage();
        print('inactive: saved to local storage');
        break;
      case AppLifecycleState.paused:
        saveLocalStorage();
        print('paused: saved to local storage');
        break;
      case AppLifecycleState.detached:
        saveLocalStorage();
        print('detached: saved to local storage');
        break;
    }
  }

  void loadData() async {
    await storage.ready;
    if (storage.getItem('petType') == 'octo-egg' || storage.getItem('petType') == null) {
      storage.setItem('petType', 'octo-egg');
    } else if (storage.getItem('petType') == 'octo-ghost') {
      storage.setItem('petType', 'octo-ghost');
    } else {
      print("Local sotrage data has been found, loading now...");
      loadLocalStorage();
    }
  }

  void resetLocalStorage() async {
    await storage.ready;
    storage.deleteItem('petType');
    storage.deleteItem('petIndex');
    storage.deleteItem('petDob');
    storage.deleteItem('petHunger');
    storage.deleteItem('petHappiness');
    storage.deleteItem('petHealth');
    storage.deleteItem('petLevel');
    storage.deleteItem('petPreviousDateTime');
  }

  void saveLocalStorage() async {
    await storage.ready;
    storage.setItem('petHunger', petHunger);
    storage.setItem('petHappiness', petHappiness);
    storage.setItem('petHealth', petHealth);
    storage.setItem('petLevel', petLevel);
    storage.setItem('petPreviousDateTime', DateTime.now().toString());
    print('Saving value petPreviousDateTime as : ${DateTime.now().toString()}');
  }

  calculateTimeStatDifference() {
    if (petType != 'octo-egg' && petType != 'octo-ghost') {
      int incrementModifier = 2;
      DateTime recordedTime = petPreviousDateTime;
      DateTime currentTime = DateTime.now();
      final difference = currentTime.difference(recordedTime);

      print("""
        The current petHunger is: ${petHunger}
        The currentTime is ${currentTime.toString()}
        and the last recored playtime was ${recordedTime.toString()}
        The difference between these is: ${difference.toString()}
        The differnce in seconds is: ${difference.inSeconds}
        """);

      // Calculate Hunger, Happiness and Health Changes
      if ((petHunger - difference.inSeconds) < incrementModifier) {
        print("""
          petHunger - difference.inSeconds = ${petHunger - difference.inSeconds}
          setting petHunger to ${incrementModifier}
        """);
        setState(() {
          petHunger = incrementModifier;
        });
      } else {
        print("""
          petHunger - difference.inSeconds = ${petHunger - difference.inSeconds}
          setting petHunger to ${petHunger -= difference.inSeconds}
        """);
        setState(() {
          petHunger -= difference.inSeconds;
        });
      }
    }
  }

  void loadLocalStorage() async {
    await storage.ready;
    print("Loading last recorded stats...");
    setState(() {
      petType = storage.getItem('petType');
      petIndex = storage.getItem('petIndex');
      petDob = DateTime.parse(storage.getItem('petDob'));
      petHunger = storage.getItem('petHunger');
      petHappiness = storage.getItem('petHappiness');
      petHealth = storage.getItem('petHealth');
      petLevel = storage.getItem('petLevel');
      petHistory = storage.getItem('petHistory');
      petPreviousDateTime = DateTime.parse(storage.getItem('petPreviousDateTime'));
    });
    print("""
        LOCAL STORAGE: DOES NOT CONTAIN PREVIOUS TIME!!!
        petType: ${petType}
        petIndex: ${petIndex}
        petDob: ${petDob}
        petHunger: ${petHunger}
        petHappiness: ${petHappiness}
        petHealth: ${petHealth}
        petLevel: ${petLevel}
        petHistory: ${petHistory}
        petPreviousDateTime: ${petPreviousDateTime}
      """);
    calculateTimeStatDifference();
  }

  void poof() async {
    audioPoof.play();
    await storage.ready;
    resetLocalStorage();
    String currentPetHistory = storage.getItem('petHistory');
    String updatedPetHistory = currentPetHistory +
        '${petType}:${petIndex.toString()}:${petDob.toString()}:${petLevel.toString()}, ';
    storage.setItem('petHistory', updatedPetHistory);
    petType = 'octo-ghost';
    petIndex = '0';
    petDob = DateTime.now();
    petLevel = 1;
    petHunger = 100;
    petHappiness = 100;
    petHealth = 100;
    petMood = '';
    showMenu = false;
    eating = false;
    waste = false;
  }

  void gameLoop() async {
    // Game Loop
    Timer.periodic(Duration(milliseconds: gameTickerDuration), (timer) {
      setState(() => gameTicker++);
      int incrementModifier = 2;
      int positiveModifier = 4;
      int actionModifier = 25;
      int minimumModifier = 0;
      int medianModifier = 50;
      int semiMaximumModifier = 75;
      int maximumModifier = 100;

      if (petType != 'octo-egg' && petType != 'octo-ghost') {
        // Hunger Loop
        if (petHunger > minimumModifier) {
          setState(() {
            petHunger -= incrementModifier;
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
          });
        }
        if (petHunger >= semiMaximumModifier && petHappiness <= semiMaximumModifier) {
          petHappiness += positiveModifier;
        }
        // Health Loop
        if (petHunger == minimumModifier &&
            petHappiness == minimumModifier &&
            petHealth > minimumModifier) {
          setState(() {
            petHealth -= incrementModifier;
          });
        } else if (petHunger >= semiMaximumModifier &&
            petHappiness >= semiMaximumModifier &&
            petHealth < maximumModifier) {
          setState(() {
            petHealth += positiveModifier;
          });
        }
        // Emotes/Emotions
        if (petHunger >= medianModifier &&
            petHappiness >= medianModifier &&
            petHealth >= medianModifier) {
          setState(() {
            petMood = 'happy';
          });
        }
        if (petHunger >= semiMaximumModifier &&
            petHappiness >= semiMaximumModifier &&
            petHealth >= semiMaximumModifier) {
          setState(() {
            petMood = 'love';
          });
        }
        if (petHunger == minimumModifier) {
          setState(() {
            petMood = 'hungry';
          });
        }
        if (petHappiness <= medianModifier) {
          setState(() {
            petMood = 'bored';
          });
        }
        if (petHappiness == minimumModifier) {
          setState(() {
            petMood = 'blank';
          });
        }
        if (petHealth <= semiMaximumModifier) {
          setState(() {
            petMood = 'sad';
          });
        }
        if (petHealth <= minimumModifier) {
          // Poof!!!
          poof();
        }
        print('petHunger   : ${petHunger}');
        //print('petHappiness: ${petHappiness}');
        //print('petHealth   : ${petHealth}');
        //print('/////////////////');
      }
    });
  }

  actionMenu() {
    if (petType != 'octo-egg' && petType != 'octo-ghost') {
      return Row(
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
      );
    } else if (petType == 'octo-egg') {
      return Row(
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
      );
    } else if (petType == 'octo-ghost') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                actionSpawnNewEgg();
              },
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Try Again!",
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  actionSpawnNewEgg() async {
    setState(() {
      petType = 'octo-egg';
      audioEgg.play();
      storage.setItem('petType', petType);
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
        DateTime petDateOfBirth = DateTime.now();
        String newPetType = '';
        if (randomPetType >= 91 && randomPetType <= 100) {
          newPetType = 'octo-bot';
        } else if (randomPetType >= 0 && randomPetType <= 30) {
          newPetType = 'octo-dog';
        } else if (randomPetType >= 31 && randomPetType <= 60) {
          newPetType = 'octo-bat';
        } else if (randomPetType >= 61 && randomPetType <= 90) {
          newPetType = 'octo-fox';
        }
        print("PetType: ${randomPetType}");
        print("No saved data found, creating now...");
        await storage.ready;
        storage.setItem('petIndex', randomPetIndex.toString());
        storage.setItem(
          'petDob',
          petDateOfBirth.toString(),
        );
        storage.setItem('petHunger', 100);
        storage.setItem('petHappiness', 100);
        storage.setItem('petHealth', 100);
        storage.setItem('petLevel', 1);

        if (storage.getItem('petHistory') == null) {
          storage.setItem('petHistory', '');
          print(storage.getItem('petHistory'));
        } else {
          print('YES YES YES pet history found:');
          print(storage.getItem('petHistory'));
        }
        print("New Egg has been saved to local storage!");
        print("History: ${newPetType},${randomPetIndex.toString()},${petDateOfBirth},");
        storage.setItem('petType', newPetType);
        loadLocalStorage();
        hatchMsg = 'Hatch me!';
        hatchCount = 0;
        audioSpawn.play();
      }
    }
  }

  actionCheckEmotion() {
    if (petType != 'octo-egg' && petType != 'octo-ghost') {
      audioUI.play();
      if (showEmote == false) {
        setState(() {
          showEmote = true;
        });
        Future.delayed(const Duration(milliseconds: 3000), () {
          setState(() {
            showEmote = false;
          });
        });
      }
    }
  }

  actionCleanWaste() {
    setState(() {
      audioClean.play();
      petHappiness += 4;
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
    if (eating == false && petType != 'octo-egg' && petType != 'octo-ghost') {
      setState(() {
        audioUI.play();
        eating = true;
        Future.delayed(const Duration(milliseconds: 4000)).then((_) {
          eating = false;
          petHunger = 100;
          audioFull.play();
        });
      });
    }
  }

  actionPlay() {
    audioUI.play();
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
    } else if (petType == 'octo-bot') {
      return Image.asset(
        petBotSprites[gameTicker % petBotSprites.length],
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      );
    } else if (petType == 'octo-ghost') {
      return Image.asset(
        petGhostSprites[gameTicker % petGhostSprites.length],
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
    if (waste == true && petType != 'octo-egg' && petType != 'octo-ghost') {
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
    if (showEmote == true) {
      return Positioned(
        bottom: MediaQuery.of(context).size.width * 0.75,
        left: 0,
        right: 0,
        child: Image.asset(
          'assets/images/emotes/emote_$petMood.png',
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return Positioned(
        bottom: MediaQuery.of(context).size.width * 0.75,
        left: 0,
        right: 0,
        child: const SizedBox(
          width: 0,
          height: 0,
        ),
      );
    }
  }

  showFood() {
    if (eating == true && petType != 'octo-egg' && petType != 'octo-ghost') {
      return Positioned(
        bottom: 0,
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 3000),
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
                        child: actionMenu(),
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
