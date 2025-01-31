import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? error;
  final String hintText;
  final Icon icon;
  final bool isPassword;
  final bool isNumber;
  final int maxLines;

  const CustomTextField({
    Key? key,
    this.isNumber = false,
    required this.controller,
    this.error,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    isPasswordVisible = !widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          keyboardType: widget.isNumber
              ? TextInputType.number
              : (widget.hintText.toLowerCase().contains('email')
                  ? TextInputType.emailAddress
                  : TextInputType.text),
          controller: widget.controller,
          obscureText: widget.isPassword && !isPasswordVisible,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.0),
              borderSide: BorderSide(
                color: widget.error != null ? Colors.red : Colors.grey,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.0),
              borderSide: BorderSide(
                color: widget.error != null
                    ? Colors.red
                    : Color.fromARGB(255, 30, 123, 179),
                width: 1.0,
              ),
            ),
            hintText: widget.hintText,
            prefixIcon: widget.icon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color.fromARGB(255, 30, 123, 179),
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              widget.error!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
