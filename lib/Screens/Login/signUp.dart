import 'package:flutter/material.dart';
import 'package:posh/API/loginApi.dart';
import 'package:posh/Screens/Login/login.dart';
import 'package:posh/Widgets/customButton.dart';
import 'package:posh/Widgets/customTextFeild.dart';
import 'package:posh/Widgets/heading.dart';
import 'package:posh/Widgets/otherOptions.dart';

class Signup extends StatefulWidget {
  final String userType;
  const Signup({super.key, required this.userType});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? emailError;
  String? usernameError;
  String? phoneError;

  bool isValidEmail(String email, String userType) {
    final userRegex = RegExp(r"^[nsro]\d{6}@rguktn\.ac\.in$");
    final staffRegex = RegExp(r"^[a-zA-Z]{2}[a-zA-Z0-9_]@rgukt[a-z]\.ac\.in$");

    if (userType == 'user') {
      return userRegex.hasMatch(email);
    } else if (userType == 'staff') {
      return staffRegex.hasMatch(email);
    }
    return false; 
  }
  void validateFields() async {
    setState(() {
      emailError = null;
      usernameError = null;
      phoneError = null;

      if (usernameController.text.isEmpty) {
        usernameError = 'Username cannot be empty';
      }
      if (emailController.text.isEmpty) {
        emailError = 'Email cannot be empty';
      } else if (!isValidEmail(emailController.text, widget.userType)) {
        emailError = 'Enter a valid email address';
      }
      if (phoneController.text.isEmpty) {
        phoneError = 'Mobile number cannot be empty';
      } else if (phoneController.text.length != 10) {
        phoneError = 'Enter a valid phone number';
      }
    });

    if (usernameError != null || emailError != null || phoneError != null) {
      return; // Stop further execution if there are validation errors
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Loginapi().checkEmail(
        emailController.text.trim(),
        usernameController.text.trim(),
        phoneController.text.trim(),
        widget.userType,
        context,
        (emailErr) {
          setState(() {
            emailError = emailErr;
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/img/head.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Heading(text: 'Sign Up'),
                        SizedBox(height: 30),
                        CustomTextField(
                          controller: usernameController,
                          hintText: 'Username',
                          icon: Icon(Icons.person_outline),
                          error: usernameError,
                        ),
                        SizedBox(height: 25),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Email',
                          icon: Icon(Icons.email_outlined),
                          error: emailError,
                        ),
                        SizedBox(height: 25),
                        CustomTextField(
                          controller: phoneController,
                          hintText: 'Mobile Number',
                          icon: Icon(Icons.call_outlined),
                          error: phoneError,
                          isNumber: true,
                        ),
                        SizedBox(height: 30),
                        customButton(
                          isLoading: isLoading,
                          function: isLoading
                              ? () {}
                              : () {
                                  validateFields();
                                },
                          color: Color.fromARGB(255, 30, 123, 179),
                          textColor: Colors.white,
                          text: 'Next',
                        ),
                        SizedBox(height: 20),
                        Otheroptions(
                          text1: 'Already have an account? ',
                          text2: 'Login',
                          color: Colors.black,
                          tColor: Color.fromARGB(255, 30, 123, 179),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
