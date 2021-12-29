import 'dart:async';
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
  late List<String> petHistoryList = widget.petHistory.split(',');

  petHistorySprite(pet) {
    if (pet == 'octo-fox') {
      return 'assets/images/pet1_layer1.png';
    } else if (pet == 'octo-bat') {
      return 'assets/images/pet2_layer1.png';
    } else if (pet == 'octo-dog') {
      return 'assets/images/pet3_layer1.png';
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
                  Padding(
                    padding: const EdgeInsets.only(
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
                      itemCount: petHistoryList.length,
                      padding: const EdgeInsets.all(15.0),
                      itemBuilder: (context, index) {
                        List<String> pet = widget.petHistory.split(':');
                        return Container(
                          padding: const EdgeInsets.only(
                            bottom: 60.0,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.33,
                                child: Image.asset(
                                  petHistorySprite(pet[0]),
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    pet[0].replaceAll(",", ""),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    'Octo-ID: ${pet[1].replaceAll(",", "")}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'Hatch: ${pet[2].replaceAll(",", "")}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'POOF: ${pet[2].replaceAll(",", "")}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
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
