import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  Function hideMenu;
  String petHistory;
  MenuWidget({Key? key, required this.hideMenu, showMenu, required this.petHistory})
      : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  _MenuWidgetState();
  late List<String> petHistoryList = widget.petHistory.split(', ');

  petHistorySprite(pet) {
    if (pet == 'octo-fox') {
      return 'assets/images/pet1_layer1.png';
    } else if (pet == 'octo-bat') {
      return 'assets/images/pet2_layer1.png';
    } else if (pet == 'octo-dog') {
      return 'assets/images/pet3_layer1.png';
    } else if (pet == 'octo-bot') {
      return 'assets/images/pet4_layer1.png';
    } else if (pet == 'octo-ox') {
      return 'assets/images/pet5_layer1.png';
    } else {
      return 'assets/images/egg2.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      bottom: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 10.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF59734a).withOpacity(0.95),
                border: Border.all(
                  width: 6.0,
                  color: const Color(0xFF222222),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 30.0,
                      bottom: 30.0,
                    ),
                    child: Text(
                      "History",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: petHistoryList.length - 1,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      itemBuilder: (context, index) {
                        List<String> pet = petHistoryList[index].split('/');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 30.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: Image.asset(
                                  petHistorySprite(pet[0]),
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 5.0,
                                      ),
                                      child: Text(
                                        pet[0],
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      'Level: ${pet[2]}',
                                      style: TextStyle(fontSize: 10, height: 1.5),
                                    ),
                                    Text(
                                      'Age: ${DateTime.parse(pet[4]).difference(DateTime.parse(pet[3])).inDays} days',
                                      style: TextStyle(fontSize: 10, height: 1.5),
                                    ),
                                    Text(
                                      'Hatch: ${DateTime.parse(pet[3]).month}/${DateTime.parse(pet[3]).day}/${DateTime.parse(pet[3]).year}',
                                      style: TextStyle(fontSize: 10, height: 1.5),
                                    ),
                                    Text(
                                      'Poof: ${DateTime.parse(pet[4]).month}/${DateTime.parse(pet[4]).day}/${DateTime.parse(pet[4]).year}',
                                      style: TextStyle(fontSize: 10, height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.hideMenu();
              },
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Back",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
