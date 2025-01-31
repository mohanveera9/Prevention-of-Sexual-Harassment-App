import 'package:flutter/material.dart';
import 'package:posh/Screens/Login/ForgetPassord/Step1.dart';
import 'package:posh/Screens/Login/ForgetPassord/Step2.dart';
import 'package:posh/Screens/Login/ForgetPassord/Step3.dart';
import 'package:posh/Screens/Login/login.dart';

class ForgetPassword extends StatefulWidget {
  final String userType;
  const ForgetPassword({
    super.key,
    required this.userType,
  });

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  int currentStep = 1;
  String email = ''; // Store the email from Step1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Image.asset(
              'assets/img/head.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Steps Container
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepIndicator(currentStep >= 1), // Step 1
                      _buildLine(currentStep >= 2), // Line after Step 1
                      _buildStepIndicator(currentStep >= 2), // Step 2
                      _buildLine(currentStep >= 3), // Line after Step 2
                      _buildStepIndicator(currentStep == 3), // Step 3
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Step Widgets
                  if (currentStep == 1)
                    Step1(
                      onNext: (String enteredEmail) {
                        setState(() {
                          email = enteredEmail;
                          currentStep = 2;
                        });
                      },
                    ),
                  if (currentStep == 2)
                    Step2(
                      email: email,
                      onNext: () {
                        setState(() {
                          currentStep = 3;
                        });
                      },
                    ),
                  if (currentStep == 3)
                    Step3(
                      email: email,
                      onNext: () {
                        // Final logic after Step 3 is completed
                        showSnackbar('Password reset completed!', Colors.green);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (builder) => Login(userType: widget.userType,),
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
    );
  }

  Widget _buildStepIndicator(bool isCompleted) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 3,
        color: isCompleted ? Colors.green : Colors.grey,
      ),
    );
  }

  // Helper function to show a Snackbar
  void showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
