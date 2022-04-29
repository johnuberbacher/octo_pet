import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_pet/components/ui.dart';
import 'package:octo_pet/components/menu.dart';
import 'package:octo_pet/components/waste.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:animated_widgets/animated_widgets.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  final LocalStorage storage = LocalStorage('petData.json');

  int gameTicker = 0;
  int gameTickerDuration = 1000;
  int minimumModifier = 0; // zero - always keep at 0
  int incrementModifier = 1; // random between 1 & 2
  int positiveModifier = 4320; //   1/10
  int quarterModifier = 10800; //   1/4th
  int medianModifier = 21600; //   1/2
  int maximumModifier = 3600; //  4/4
  int petLevel = 1;
  int petHunger = 3600; //  4/4
  int petHappiness = 3600; //  4/4
  int petHealth = 3600; //  1/4
  late int semiMaximumModifier = maximumModifier; //   3/4

  String petType = 'octo-egg';
  String petIndex = '0';
  String petMood = '';
  String petHistory = '';
  double top = 0;
  double left = 0;

  double fruitTop = 0;
  double fruitLeft = 0;
  List<dynamic> wasteList = [
    [0.0, 0.0],
    [100.0, 150.0],
    [150.0, 250.0]
  ];

  double dragXOffset = 16;
  double dragYOffset = 236;

  DateTime petDob = DateTime.now();
  DateTime petPreviousDateTime = DateTime.now();

  List<int> petModifierRate = [0, 0, 0];

  final eggSprites = ['assets/images/egg1.png', 'assets/images/egg2.png'];
  final petFoxSprites = ['assets/images/pet1_layer1.png', 'assets/images/pet1_layer2.png'];
  final petBatSprites = ['assets/images/pet2_layer1.png', 'assets/images/pet2_layer2.png'];
  final petDogSprites = ['assets/images/pet3_layer1.png', 'assets/images/pet3_layer2.png'];
  final petOxSprites = ['assets/images/pet5_layer1.png', 'assets/images/pet5_layer2.png'];
  final petBotSprites = ['assets/images/pet4_layer1.png', 'assets/images/pet4_layer2.png'];
  final petGhostSprites = ['assets/images/ghost_layer1.png', 'assets/images/ghost_layer2.png'];
  final wasteSprites = ['assets/images/waste1.png', 'assets/images/waste2.png'];
  final playSprites = ['assets/images/play1.png', 'assets/images/play2.png'];
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
  bool playing = false;
  bool waste = false;
  bool showEmote = false;

  bool fruitActive = false;

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
      case AppLifecycleState.resumed:
        loadLocalStorage();
        print('resumfed: loaded local storage');
        break;
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
    print("///////////////////////////////////////////////");
    print("""
        SAVING STORAGE:
        petHunger: ${petHunger}
        petHappiness: ${petHappiness}
        petHealth: ${petHealth}
        petPreviousDateTime: ${petPreviousDateTime}
      """);
    print("///////////////////////////////////////////////");
  }

  calculateTimeStatDifference() {
    if (petType != 'octo-egg' && petType != 'octo-ghost') {
      int snapShotPetHunger = petHunger;
      int snapShotPetHappiness = petHappiness;
      int snapShotPetHealth = petHealth;
      DateTime recordedTime = petPreviousDateTime;
      DateTime currentTime = DateTime.now();
      final difference = currentTime.difference(recordedTime);
      print("the difference is ${difference.inSeconds}");

      // Pet Hunger
      if (snapShotPetHunger <=
          (difference.inSeconds + (difference.inSeconds * (petModifierRate[0] ~/ 10)))) {
        setState(() {
          petHunger = minimumModifier;
        });
      } else {
        setState(() {
          petHunger = snapShotPetHunger -
              (difference.inSeconds + (difference.inSeconds * (petModifierRate[0] ~/ 10)));
        });
      }
      // Pet Happiness
      if (snapShotPetHappiness <=
          (difference.inSeconds + (difference.inSeconds * (petModifierRate[1] ~/ 10)))) {
        setState(() {
          petHappiness = minimumModifier;
        });
      } else {
        setState(() {
          petHappiness = snapShotPetHappiness -
              (difference.inSeconds + (difference.inSeconds * (petModifierRate[1] ~/ 10)));
        });
      }

      // Pet Health
      if (snapShotPetHealth <=
          ((difference.inSeconds + (difference.inSeconds * (petModifierRate[0] ~/ 10))) +
              (difference.inSeconds + (difference.inSeconds * (petModifierRate[1] ~/ 10))))) {
        setState(() {
          petHealth = minimumModifier;
        });
      } else {
        setState(() {
          petHappiness = snapShotPetHappiness -
              ((difference.inSeconds + (difference.inSeconds * (petModifierRate[0] ~/ 10))) +
                  (difference.inSeconds + (difference.inSeconds * (petModifierRate[1] ~/ 10))));
        });
      }

      // Calculate Level
      final calculateLevel = currentTime.difference(petDob);
      setState(() {
        petLevel = calculateLevel.inDays + 1;
      });
    }
  }

  void loadLocalStorage() async {
    await storage.ready;
    print("Loading last recorded stats...");
    print("///////////////////////////////////////////////");
    setState(() {
      petType = storage.getItem('petType');
      petIndex = storage.getItem('petIndex');
      petDob = DateTime.parse(storage.getItem('petDob'));
      petHunger = storage.getItem('petHunger');
      petHappiness = storage.getItem('petHappiness');
      petHealth = storage.getItem('petHealth');
      petLevel = storage.getItem('petLevel');
      petHistory = storage.getItem('petHistory');
      if (storage.getItem('petPreviousDateTime') != null) {
        petPreviousDateTime = DateTime.parse(storage.getItem('petPreviousDateTime'));
      }
    });
    if (petType == 'octo-fox') {
      setState(() {
        petModifierRate = [2, 0, 1];
      });
    } else if (petType == 'octo-dog') {
      setState(() {
        petModifierRate = [2, 1, 0];
      });
    } else if (petType == 'octo-bat') {
      setState(() {
        petModifierRate = [1, 2, 0];
      });
    } else if (petType == 'octo-ox') {
      setState(() {
        petModifierRate = [0, 2, 1];
      });
    } else if (petType == 'octo-bot') {
      setState(() {
        petModifierRate = [1, 1, 1];
      });
    } else {
      setState(() {
        petModifierRate = [0, 0, 0];
      });
    }
    calculateTimeStatDifference();
    print("""
        LOCAL STORAGE:
        petType: ${petType}
        petIndex: ${petIndex}
        petDob: ${petDob}
        petHunger: ${petHunger}
        petHappiness: ${petHappiness}
        petHealth: ${petHealth}
        petModifierRate: ${petModifierRate}
        petLevel: ${petLevel}
        petHistory: ${petHistory}
        petPreviousDateTime: ${petPreviousDateTime}
      """);
  }

  void poof() async {
    audioPoof.play();
    await storage.ready;
    resetLocalStorage();
    String currentPetHistory = storage.getItem('petHistory');
    String updatedPetHistory = currentPetHistory +
        '${petType}/${petIndex.toString()}/${petLevel.toString()}/${petDob.toString()}/${(DateTime.now()).toString()}, ';
    print(updatedPetHistory);
    await storage.setItem('petHistory', updatedPetHistory);
    print('GOT HERE');
    setState(() {
      petType = 'octo-ghost';
      petIndex = '0';
      petDob = DateTime.now();
      petLevel = 1;
      petHunger = maximumModifier;
      petHappiness = maximumModifier;
      petHealth = maximumModifier;
      petMood = '';
      showMenu = false;
      eating = false;
      waste = false;
    });
    print('GOT HERE');
  }

  void gameLoop() async {
    // Game Loop
    Timer.periodic(Duration(milliseconds: gameTickerDuration), (timer) {
      print('''
        petHunger   :  ${petHunger} / ${maximumModifier}
        petHappiness:  ${petHappiness} / ${maximumModifier}
        petHealth   :  ${petHealth} / ${maximumModifier}
        petMood     :  ${petMood} 
        petDob     :  ${petDob} 
        currentTime     :  ${DateTime.now()} 
        wasteActive     :  ${waste} 
        petModifierRate     :  ${petModifierRate} 
        ///////////////////////////////////////////////////////''');
      //print('petHappiness: ${petHappiness}');
      //print('petHealth   : ${petHealth}');
      //print('/////////////////');
      print(wasteList);
      setState(() => gameTicker++);
      if (petType != 'octo-egg' && petType != 'octo-ghost') {
        // Hunger Loop
        if (petHunger > minimumModifier) {
          int incrementModifier = (Random().nextInt(3 - 0 + 1) + 0).toInt();
          if (petHunger - (incrementModifier + petModifierRate[0]) < minimumModifier) {
            setState(() {
              petHunger = minimumModifier;
            });
          } else {
            setState(() {
              petHunger -= (incrementModifier + petModifierRate[0]);
            });
          }
        }
        // Happiness Loop
        if (petHappiness > minimumModifier) {
          int incrementModifier = (Random().nextInt(3 - 0 + 1) + 0).toInt();
          if (petHappiness - (incrementModifier + petModifierRate[1]) < minimumModifier) {
            setState(() {
              petHappiness = minimumModifier;
            });
          } else {
            setState(() {
              petHappiness -= (incrementModifier + petModifierRate[1]);
            });
          }
        }
        // Health Loop
        if (petHunger <= minimumModifier &&
            petHappiness <= minimumModifier &&
            petHealth > minimumModifier) {
          //(max - min + 1) + min
          int incrementModifier = (Random().nextInt(3 - 0 + 1) + 0).toInt();
          if (petHealth - (incrementModifier + petModifierRate[2]) < minimumModifier) {
            setState(() {
              petHealth = minimumModifier;
            });
          } else {
            setState(() {
              petHealth -= (incrementModifier + petModifierRate[2]);
            });
          }
        }
        // Waste Loop
        if (petHunger <= semiMaximumModifier) {
          int randomWasteEncounter = (Random().nextInt(100) + 1);
          // 15/100 chance every tick to show waste
          if (randomWasteEncounter <= 75) {
            int maxWidth =
                (MediaQuery.of(context).size.width - ((MediaQuery.of(context).size.width / 3)))
                    .toInt();
            int maxHeight = (MediaQuery.of(context).size.height -
                    ((MediaQuery.of(context).size.width / 3.5) * 3.75))
                .toInt();
            setState(() {
              wasteList.add([
                (Random().nextInt(maxWidth)).toDouble(),
                (Random().nextInt(maxHeight)).toDouble()
              ]);
            });
            if (waste == false) {
              setState(() {
                waste = true;
              });
            }
          }
        }
        // Emotes/Emotions Loop
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
        if (petHunger <= minimumModifier) {
          setState(() {
            petMood = 'hungry';
          });
        }
        if (petHappiness <= medianModifier) {
          setState(() {
            petMood = 'bored';
          });
        }
        if (petHappiness <= minimumModifier) {
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
      }
    });
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
        petModifierRate = [0, 0, 0];
        if (randomPetType >= 90 && randomPetType <= 100) {
          newPetType = 'octo-bot';
        } else if (randomPetType >= 0 && randomPetType <= 24) {
          newPetType = 'octo-dog';
        } else if (randomPetType >= 25 && randomPetType <= 44) {
          newPetType = 'octo-bat';
        } else if (randomPetType >= 45 && randomPetType <= 64) {
          newPetType = 'octo-fox';
        } else if (randomPetType >= 65 && randomPetType <= 90) {
          newPetType = 'octo-ox';
        }
        print("PetType: ${randomPetType} - ${newPetType}");
        print("///////////////////////////////////////////////");
        await storage.ready;
        storage.setItem('petIndex', randomPetIndex.toString());
        storage.setItem('petDob', petDateOfBirth.toString());
        storage.setItem('petHunger', maximumModifier);
        storage.setItem('petHappiness', maximumModifier);
        storage.setItem('petHealth', maximumModifier);
        storage.setItem('petLevel', 1);
        if (storage.getItem('petHistory') == null) {
          storage.setItem('petHistory', '');
          print("No saved histroy, new PetHistory has been saved:");
          print(storage.getItem('petHistory'));
          print("///////////////////////////////////////////////");
        } else {
          print('Saved PetHistory has been found in local storage:');
          print(storage.getItem('petHistory'));
          print("///////////////////////////////////////////////");
        }
        storage.setItem('petType', newPetType);
        print("Upon Egg Creation, PetHistory now is: $petHistory");
        print("///////////////////////////////////////////////");
        loadLocalStorage();
        hatchMsg = 'Hatch me!';
        hatchCount = 0;
        audioSpawn.play();
      }
    }
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
                poof();
              },
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Poof",
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  fruitActive = true;
                });
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

  actionCleanWaste(int i) {
    if (waste == true) {
      setState(() {
        audioClean.play();
        petHappiness += 4;
        wasteList.removeAt(i);
      });
    }
  }

  actionHideMenu() {
    print(petHistory);
    setState(() {
      audioUI.play();
      showMenu = !showMenu;
    });
  }

  actionFeed() {
    if (playing == false && eating == false && petType != 'octo-egg' && petType != 'octo-ghost') {
      audioUI.play();
      setState(() {
        showEmote = false;
        eating = true;
      });
      Future.delayed(const Duration(milliseconds: 3000)).then((_) {
        eating = false;
        if ((petHunger + positiveModifier) >= maximumModifier) {
          setState(() {
            petHunger = maximumModifier;
          });
        } else {
          setState(() {
            petHunger += positiveModifier;
          });
        }
        audioFull.play();
      });
    }
  }

  actionPlay() {
    if (playing == false && eating == false && petType != 'octo-egg' && petType != 'octo-ghost') {
      audioUI.play();
      setState(() {
        showEmote = false;
        playing = true;
      });
      Future.delayed(const Duration(milliseconds: 3000)).then((_) {
        playing = false;
        if ((petHappiness + positiveModifier) >= maximumModifier) {
          setState(() {
            petHappiness = maximumModifier;
          });
        } else {
          setState(() {
            petHappiness += positiveModifier;
          });
        }
        audioFull.play();
        actionCheckEmotion();
      });
    }
  }

  showPet() {
    switch (petType) {
      case 'octo-fox':
        return Image.asset(
          petFoxSprites[gameTicker % petFoxSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
      case 'octo-dog':
        return Image.asset(
          petDogSprites[gameTicker % petDogSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
      case 'octo-bat':
        return Image.asset(
          petBatSprites[gameTicker % petBatSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
      case 'octo-bot':
        return Image.asset(
          petBotSprites[gameTicker % petBotSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
      case 'octo-ox':
        return Image.asset(
          petOxSprites[gameTicker % petOxSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
      case 'octo-ghost':
        return Image.asset(
          petGhostSprites[gameTicker % petGhostSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
      default:
        return Image.asset(
          eggSprites[gameTicker % eggSprites.length],
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.width / 3.5,
        );
    }
  }

  showFruit() {
    if (fruitActive == true && petType != 'octo-egg' && petType != 'octo-ghost') {
      return Positioned(
        top: fruitTop,
        left: fruitLeft,
        child: Container(
          child: Draggable<String>(
            data: 'fruit',
            child: Image.asset(
              fruitSprites[gameTicker % 1],
              fit: BoxFit.cover,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 3.5,
              height: MediaQuery.of(context).size.width / 3.5,
            ),
            feedback: Transform.scale(
              // (b).
              scale: 1 - 0,
              child: ShakeAnimatedWidget(
                enabled: true,
                duration: Duration(milliseconds: 250),
                shakeAngle: Rotation.deg(z: 15),
                curve: Curves.linear,
                child: Image.asset(
                  fruitSprites[gameTicker % 1],
                  fit: BoxFit.fitHeight,
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: MediaQuery.of(context).size.width / 3.5,
                ),
              ),
            ),
            childWhenDragging: Container(),
            onDragEnd: (dragDetails) {
              setState(() {
                if (dragDetails.offset.dx - dragXOffset <= 0) {
                  fruitLeft = 0;
                } else if ((dragDetails.offset.dx * 1.5) >= (MediaQuery.of(context).size.width)) {
                  fruitLeft = (MediaQuery.of(context).size.width) -
                      MediaQuery.of(context).size.width / 2.66;
                } else {
                  fruitLeft = dragDetails.offset.dx - dragXOffset;
                }

                if (dragDetails.offset.dy - dragYOffset <= 0) {
                  fruitTop = 0;
                } else if ((dragDetails.offset.dy * 1.5) >= (MediaQuery.of(context).size.height)) {
                  fruitTop = (MediaQuery.of(context).size.height) -
                      MediaQuery.of(context).size.width / 2.66;
                } else {
                  fruitTop = dragDetails.offset.dy - dragYOffset;
                }
              });
            },
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
        bottom: 0,
        top: -MediaQuery.of(context).size.width / 2,
        left: 0,
        right: 0,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.width / 3.5,
            child: Image.asset(
              'assets/images/emotes/emote_$petMood.png',
              fit: BoxFit.fitWidth,
            ),
          ),
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
        bottom: -MediaQuery.of(context).size.width / 3.55,
        top: 0,
        left: 0,
        right: 0,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 3000),
            child: Image.asset(
              fruitSprites[gameTicker % fruitSprites.length],
              fit: BoxFit.fitHeight,
              width: MediaQuery.of(context).size.width / 3.5,
              height: MediaQuery.of(context).size.width / 3.5,
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

  showPlay() {
    if (playing == true && petType != 'octo-egg' && petType != 'octo-ghost') {
      return Positioned(
        bottom: 0,
        top: -MediaQuery.of(context).size.width / 3.55,
        left: 0,
        right: 0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 3000),
          child: Image.asset(
            playSprites[gameTicker % playSprites.length],
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.width / 3.5,
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
        height: double.infinity,
        width: double.infinity,
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
              petType: petType,
              petDob: petDob,
              petHunger: petHunger,
              petHappiness: petHappiness,
              petHealth: petHealth,
              petLevel: petLevel,
              maximumModifier: maximumModifier,
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: petType == 'octo-egg'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: gameTickerDuration),
                                child: Image.asset(
                                  eggSprites[gameTicker % eggSprites.length],
                                  fit: BoxFit.fitWidth,
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
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 6.0,
                                color: Color(0xFF222222),
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                for (var i = 0; i < wasteList.length; i++) ...[
                                  Waste(
                                    gameTicker: gameTicker,
                                    i: i,
                                    x: wasteList[i][0],
                                    y: wasteList[i][1],
                                    function: () => actionCleanWaste(i),
                                  ),
                                ],
                                Positioned(
                                  top: top,
                                  left: left,
                                  child: DragTarget<String>(
                                    builder: (
                                      BuildContext context,
                                      List<dynamic> accepted,
                                      List<dynamic> rejected,
                                    ) {
                                      return LongPressDraggable(
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            petEmote(petMood),
                                            GestureDetector(
                                              onTap: () {
                                                actionPlay();
                                                //actionCheckEmotion();//
                                              },
                                              child: AnimatedSwitcher(
                                                duration:
                                                    Duration(milliseconds: gameTickerDuration),
                                                child: showPet(),
                                              ),
                                            ),
                                            showFood(),
                                            showPlay(),
                                          ],
                                        ),
                                        feedback: ShakeAnimatedWidget(
                                          enabled: true,
                                          duration: Duration(milliseconds: 250),
                                          shakeAngle: Rotation.deg(z: 5),
                                          curve: Curves.linear,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              petEmote(petMood),
                                              AnimatedSwitcher(
                                                duration:
                                                    Duration(milliseconds: gameTickerDuration),
                                                child: showPet(),
                                              ),
                                              showPlay(),
                                            ],
                                          ),
                                        ),
                                        childWhenDragging: Container(),
                                        onDragEnd: (dragDetails) {
                                          setState(() {
                                            left = dragDetails.offset.dx - dragXOffset;
                                            top = dragDetails.offset.dy - dragYOffset;
                                          });
                                        },
                                      );
                                    },
                                    onWillAccept: (data) {
                                      return data == 'fruit';
                                    },
                                    onAccept: (data) {
                                      setState(() {
                                        fruitActive = false;
                                        actionFeed();
                                      });
                                    },
                                  ),
                                ),
                                showFruit(),
                              ],
                            ),
                          ),
                  ),
                  showMenu
                      ? MenuWidget(
                          hideMenu: actionHideMenu, showMenu: showMenu, petHistory: petHistory)
                      : Container()
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: actionMenu(),
            )
          ],
        )),
      ),
    );
  }
}
