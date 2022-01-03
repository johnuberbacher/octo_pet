import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserInterfaceWidget extends StatefulWidget {
  final int petHunger;
  final int petHealth;
  final int petHappiness;
  final String petType;
  final DateTime petDob;
  final int petLevel;
  const UserInterfaceWidget({
    required this.petHunger,
    required this.petHealth,
    required this.petHappiness,
    required this.petType,
    required this.petDob,
    required this.petLevel,
  });

  @override
  _UserInterfaceWidgetState createState() => _UserInterfaceWidgetState();
}

class _UserInterfaceWidgetState extends State<UserInterfaceWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.petType == 'octo-ghost') {
      return Container(
          padding: const EdgeInsets.only(
            top: 45.0,
            left: 45.0,
            right: 45.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Poof!',
                style: TextStyle(fontSize: 36),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 35.0,
                ),
                child: Text(
                  'Your Octo-Pet has left.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 35.0,
                ),
                child: Text(
                  'Thanks for playing!',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ));
    } else if (widget.petType != 'octo-egg' && widget.petType != 'octo-ghost') {
      return Padding(
        padding: const EdgeInsets.all(
          10.0,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            15.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 6.0,
              color: Color(0xFF222222),
            ),
            color: Color(0xFF59734a).withOpacity(0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.petType,
                      style: TextStyle(fontSize: 28),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateTime(widget.petDob.year, widget.petDob.month, widget.petDob.day)
                              .toString()
                              .substring(0, 10)
                              .replaceAll(RegExp(r'[^\w\s]+'), '/'),
                          style: TextStyle(fontSize: 9),
                        ),
                        Text(
                          "Lvl. " + widget.petLevel.toString(),
                          style: TextStyle(fontSize: 14.25),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 5.0,
                      ),
                      child: Text(
                        "Hunger:",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 5.0,
                          width: MediaQuery.of(context).size.width,
                          color: const Color(0xFF222222).withOpacity(0.25),
                        ),
                        Container(
                          height: 5.0,
                          width: MediaQuery.of(context).size.width *
                              (widget.petHunger.toDouble() / 100),
                          color: const Color(0xFF222222),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 5.0,
                      ),
                      child: Text(
                        "Happiness:",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 5.0,
                          width: MediaQuery.of(context).size.width,
                          color: Color(0xFF222222).withOpacity(0.25),
                        ),
                        Container(
                          height: 5.0,
                          width: MediaQuery.of(context).size.width *
                              (widget.petHappiness.toDouble() / 100),
                          color: Color(0xFF222222),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 2.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 5.0,
                      ),
                      child: Text(
                        "Health:",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 5.0,
                          width: MediaQuery.of(context).size.width,
                          color: Color(0xFF222222).withOpacity(0.25),
                        ),
                        Container(
                          height: 5.0,
                          width: MediaQuery.of(context).size.width *
                              (widget.petHealth.toDouble() / 100),
                          color: Color(0xFF222222),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
