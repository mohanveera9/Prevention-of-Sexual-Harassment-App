import 'package:flutter/material.dart';
import 'package:posh/Model/connectivity_wrapper.dart';
import 'package:posh/Screens/Login/login.dart';
import 'package:posh/Screens/Login/signUp.dart';
import 'package:posh/Widgets/button.dart';
import 'package:posh/Widgets/customButton.dart';
import 'package:posh/Widgets/otherOptions.dart';

class Loginmain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Login to access exclusive features and share your feedback or complaints effectively.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: customButton(
                  isLoading: false,
                  function: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      builder: (BuildContext context) {
                        return _buildBottomSheet(context , false);
                      },
                    );
                  },
                  color: Colors.white,
                  textColor: Color(0xFF0C3F9E),
                  text: 'Login',
                ),
              ),
              SizedBox(height: 20),
              Otheroptions(
                text1: 'Don\'t have an account? ',
                text2: 'Sign Up',
                function: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      builder: (BuildContext context) {
                        return _buildBottomSheet(context , true);
                      },
                    );
                },
                color: Colors.white,
                tColor: Color(0xFF0C3F9E),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, bool isSignUp ) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 7,
            width: 80,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(20)),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Choose your role',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40),
          Button(
            text: 'Student',
            function: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (builder) => isSignUp ? Signup(userType: 'user',) : Login(userType: 'user'),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Button(
              text: 'Faculty',
              function: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (builder) => isSignUp ? Signup(userType: 'staff',) : Login(userType: 'staff',),
                  ),
                );
              }),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
