import 'package:flutter/material.dart';
import 'package:posh/API/loginApi.dart';
import 'package:posh/Screens/Login/ForgetPassord/forgetPassword.dart';
import 'package:posh/Screens/Login/signUp.dart';
import 'package:posh/Widgets/customButton.dart';
import 'package:posh/Widgets/customTextFeild.dart';
import 'package:posh/Widgets/heading.dart';
import 'package:posh/Widgets/otherOptions.dart';

class Login extends StatefulWidget {
  final String userType;
  const Login({
    super.key,
    required this.userType,
  });

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  String? emailError;
  String? passwordError;

  void validateFields() {
    setState(() {
      emailError = emailController.text.isEmpty ? 'Enter username' : null;
      passwordError = passwordController.text.isEmpty ? 'Enter password' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
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
                        SizedBox(height: 40),
                        Heading(
                          text: 'Login',
                        ),
                        SizedBox(height: 30),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Email',
                          icon: Icon(Icons.email_outlined),
                          error: emailError,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          icon: Icon(
                            Icons.lock_outline,
                          ),
                          isPassword: true,
                          error: passwordError,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (builder) => ForgetPassword(
                                    userType: widget.userType,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 30, 123, 179),
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        customButton(
                          isLoading: isLoading,
                          function: isLoading
                              ? () {}
                              : () async {
                                  print(widget.userType);
                                  setState(() {
                                    isLoading = true;
                                    emailError = null;
                                    passwordError = null;
                                  });

                                  await Loginapi().login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    widget.userType,
                                    context,
                                    (emailErr, passwordErr) {
                                      setState(() {
                                        emailError = emailErr;
                                        passwordError = passwordErr;
                                      });
                                    },
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                          color: Color.fromARGB(255, 30, 123, 179),
                          textColor: Colors.white,
                          text: 'Login',
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text('Or'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Loginapi().googleSignUp(context, widget.userType);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/img/google_logo.png',
                                height: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Otheroptions(
                          text1: 'Don\'t have an account? ',
                          text2: 'Sign Up',
                          color: Colors.black,
                          tColor: Color.fromARGB(255, 30, 123, 179),
                          function: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Signup(
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
        ),
      );
    });
  }
}
