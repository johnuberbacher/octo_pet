import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  Function hideMenu;
  MenuWidget({Key? key, required this.hideMenu, showMenu, petHistory}) : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  _MenuWidgetState();

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
                padding: const EdgeInsets.all(
                  15.0,
                ),
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
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 30.0,
                        runAlignment: WrapAlignment.start,
                        runSpacing: 30.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.33,
                                child: Image.asset(
                                  'assets/images/pet2_layer1.png',
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "OCTO-FOX",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    "12/12/2020",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    "12/12/2020",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.33,
                                child: Image.asset(
                                  'assets/images/pet1_layer1.png',
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "OCTO-FOX",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    "12/12/2020",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    "12/12/2020",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.33,
                                child: Image.asset(
                                  'assets/images/pet1_layer1.png',
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "OCTO-FOX",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    "12/12/2020",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    "12/12/2020",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
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
