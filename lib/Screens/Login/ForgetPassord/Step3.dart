import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:posh/Widgets/customButton.dart';
import 'package:posh/Widgets/customTextFeild.dart';

class Step3 extends StatefulWidget {
  final String email;
  final VoidCallback onNext;

  const Step3({super.key, required this.email, required this.onNext});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isConfirmPasswordVisible = false;
  bool isPasswordVisible = false;
  String? passwordError;
  String? confirmPasswordError;

  void validateFields() {
    setState(() {
      passwordError = passwordController.text.isEmpty
          ? 'Password cannot be empty'
          : passwordController.text.length < 6
              ? 'Password must be at least 6 characters'
              : null;

      confirmPasswordError = confirmPasswordController.text.isEmpty
          ? 'Confirm Password cannot be empty'
          : confirmPasswordController.text != passwordController.text
              ? 'Passwords do not match'
              : null;
    });
  }

  void showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> resetPassword() async {
    validateFields();

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/reset/password');
    final body = {
      "email": widget.email,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showSnackbar('Password reset successfully!', Colors.green);
        widget.onNext();
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          passwordError = '';
          confirmPasswordError =
              responseBody['message'] ?? 'Failed to reset password';
        });
      }
    } catch (e) {
      showSnackbar('Check your internet connection', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Step 3: Set Password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: passwordController,
          hintText: 'Password',
          icon: const Icon(Icons.lock_outline),
          isPassword: true,
          error: passwordError,
        ),
        const SizedBox(height: 25),
        CustomTextField(
          controller: confirmPasswordController,
          hintText: 'Confirm Password',
          icon: const Icon(Icons.lock_outline),
          isPassword: true,
          error: confirmPasswordError,
        ),
        const SizedBox(height: 30),
        customButton(
          isLoading: isLoading,
          function: () {
            resetPassword();
          },
          color: Color.fromARGB(255, 30, 123, 179),
          textColor: Colors.white,
          text: 'Confirm',
        ),
      ],
    );
  }
}
