import 'package:flutter/material.dart';

class customButton extends StatelessWidget {
  const customButton({
    super.key,
    required this.isLoading,
    required this.function,
    required this.color,
    required this.textColor,
    required this.text,
  });

  final bool isLoading;
  final VoidCallback function;
  final Color color;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: function,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
      child: Center( 
        child: isLoading
            ? SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}
