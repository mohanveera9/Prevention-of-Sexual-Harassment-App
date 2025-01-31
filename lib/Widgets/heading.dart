import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(255, 30, 123, 179),
        ),
      ),
    );
  }
}
