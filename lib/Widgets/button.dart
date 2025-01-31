import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback function;
  const Button({
    super.key,
    required this.text,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255,30,123,179),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 13),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
