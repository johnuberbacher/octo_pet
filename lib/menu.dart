import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  Function hideMenu;
  MenuWidget({Key? key, required this.hideMenu, showStats}) : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  _MenuWidgetState();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5,
      left: 5,
      right: 5,
      bottom: 5,
      child: Container(
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
                  bottom: 5.0,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF59734a).withOpacity(0.95),
                  border: Border.all(
                    width: 6.0,
                    color: Color(0xFF222222),
                  ),
                ),
                child: const Text(
                  "Menu",
                  style: TextStyle(fontSize: 24),
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
      ),
    );
  }
}
