import 'package:flutter/material.dart';

class Otheroptions extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback function;
  final Color color;
  final Color tColor;
  const Otheroptions({
    super.key,
    required this.text1,
    required this.text2,
    required this.function,
    required this.color, required this.tColor,

  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text1,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
          GestureDetector(
            onTap: function,
            child: Text(
              text2,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: tColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
