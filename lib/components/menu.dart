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
                      padding: const EdgeInsets.all(15.0),
                      itemBuilder: (context, index) {
                        List<String> pet = petHistoryList[index].split(':');
                        return Container(
                          padding: const EdgeInsets.only(
                            bottom: 60.0,
                          ),
                          child: Column(
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
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                    ),
                                    child: Text(
                                      pet[0],
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  // Text(
                                  //  'Octo-ID: ${pet[1]}',
                                  //  style: TextStyle(fontSize: 10),
                                  // ),
                                  Text(
                                    'Level: ${pet[4]}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'Hatch: ${pet[2]}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'POOF: ${pet[2]}',
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
