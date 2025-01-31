import 'package:flutter/material.dart';
import 'package:posh/API/loginApi.dart';
import 'package:posh/Screens/Login/login.dart';
import 'package:posh/Widgets/customButton.dart';
import 'package:posh/Widgets/heading.dart';
import 'package:posh/Widgets/otherOptions.dart';

class Otp extends StatefulWidget {
  final String email;
  final String username;
  final String phone;
  final String userType;
  const Otp({
    super.key,
    required this.email,
    required this.username,
    required this.phone,
    required this.userType,
  });

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final List<TextEditingController> otpControllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(5, (_) => FocusNode());
  bool isLoading = false;
  String? otpError;

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void validateFields() {
    setState(() {
      otpError = otpControllers.any((controller) => controller.text.isEmpty)
          ? 'Please fill all fields'
          : null;
    });
  }

  void onFieldChanged(String text, int index) {
    if (text.isNotEmpty && index < otpControllers.length - 1) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
    } else if (text.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
    }
  }

  void submitOtp() async {
    validateFields();
    if (otpError != null) return;

    String otp = otpControllers.map((e) => e.text).join();
    setState(() {
      isLoading = true;
    });

    try {
      await Loginapi().verifyOtp(
        widget.email,
        widget.phone,
        otp,
        widget.username,
        widget.userType,
        context,
        (otpErr) {
          setState(() {
            otpError = otpErr;
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/img/head.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Heading(text: 'Confirm Otp'),
                  const SizedBox(height: 30),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        otpControllers.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    otpError != null ? Colors.red : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: otpFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                              ),
                              onChanged: (text) => onFieldChanged(text, index),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (otpError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        otpError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 30),
                  customButton(
                    isLoading: isLoading,
                    function: isLoading ? () {} : submitOtp,
                    color: const Color.fromARGB(255, 30, 123, 179),
                    textColor: Colors.white,
                    text: 'Verify',
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
                          builder: (context) => Login(userType: widget.userType,),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
