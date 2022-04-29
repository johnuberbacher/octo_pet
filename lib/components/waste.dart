import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Waste extends StatefulWidget {
  int gameTicker;
  int i;
  double x;
  double y;
  Function function;
  Waste({
    Key? key,
    required this.gameTicker,
    required this.i,
    required this.x,
    required this.y,
    required this.function,
  }) : super(key: key);

  @override
  _WasteState createState() => _WasteState();
}

class _WasteState extends State<Waste> {
  int gameTickerDuration = 1000;
  final wasteSprites = ['assets/images/waste1.png', 'assets/images/waste2.png'];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x,
      top: widget.y,
      child: GestureDetector(
        onTap: () {
          widget.function();
        },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: gameTickerDuration),
          child: Image.asset(
            wasteSprites[widget.gameTicker % wasteSprites.length],
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.width / 3.5,
          ),
        ),
      ),
    );
  }
}
