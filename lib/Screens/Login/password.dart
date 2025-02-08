import 'package:flutter/material.dart';
import 'package:posh/API/loginApi.dart';
import 'package:posh/Model/connectivity_wrapper.dart';
import 'package:posh/Screens/Login/login.dart';
import 'package:posh/Widgets/customButton.dart';
import 'package:posh/Widgets/customTextFeild.dart';
import 'package:posh/Widgets/heading.dart';
import 'package:posh/Widgets/otherOptions.dart';

class Password extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String userType;
  const Password({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
  });

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  String? confirmPasswordError;
  String? passwordError;
  String? phoneError;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

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

      phoneError = phoneController.text.isEmpty
          ? 'Primary number cannot be empty'
          : phoneController.text.length != 10
              ? 'Primary number must be 10 digits'
              : null;
    });
  }

  Future<void> handleSignUp() async {
    validateFields();

    // Check if there are any validation errors
    if (passwordError != null ||
        confirmPasswordError != null ||
        phoneError != null) {
      return; // Exit the function if validation fails
    }

    setState(() {
      isLoading = true;
    });

    await Loginapi().signUp(
      widget.name,
      widget.phone,
      widget.email,
      passwordController.text,
      phoneController.text,
      widget.userType,
      context,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/img/head.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Heading(text: 'Set Password'),
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Primary Number:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Color.fromARGB(255, 30, 123, 179),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text('Primary Number'),
                                content: const Text(
                                  'The primary number is the phone number that will be used for important communications, including SOS alerts.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Primary Number',
                      icon: const Icon(Icons.call_outlined),
                      error: phoneError,
                      isNumber: true,
                    ),
                    const SizedBox(height: 30),
                    customButton(
                      isLoading: isLoading,
                      function: isLoading ? () {} : handleSignUp,
                      color: const Color.fromARGB(255, 30, 123, 179),
                      textColor: Colors.white,
                      text: 'Next',
                    ),
                    const SizedBox(height: 20),
                    Otheroptions(
                      text1: 'Don\'t have an account? ',
                      text2: 'Login',
                      color: Colors.black,
                      tColor: const Color.fromARGB(255, 30, 123, 179),
                      function: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Login(
                              userType: widget.userType,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
