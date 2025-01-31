import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:posh/Model/userModel/user.dart';
import 'package:posh/Model/userProvider.dart';
import 'package:posh/Screens/Home/mainScreen.dart';
import 'package:posh/Screens/Login/otp.dart';
import 'package:posh/Screens/Login/password.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

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

void showSnakbar(String message, Color color, BuildContext context) {
  final snackbar = SnackBar(
    content: Text(message),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

String extractId(String email) {
  return email.substring(0, 7);
}

const String baseUrl = 'https://tech-hackathon-glowhive.onrender.com';

class Loginapi {
  Future<void> login(
    String email,
    String password,
    String userType,
    BuildContext context,
    Function(String? emailError, String? passwordError) onError,
  ) async {
    if (email.isEmpty && password.isEmpty) {
      onError('Email cannot be empty.', 'Password cannot be empty.');
      return;
    }

    if (email.isEmpty) {
      onError('Email cannot be empty.', null);
      return;
    }

    if (password.isEmpty) {
      onError(null, 'Password cannot be empty.');
      return;
    }

    if (!isValidEmail(email, userType)) {
      onError('Please use a valid RGUKT email.', null);
      return;
    }

    final url = Uri.parse('$baseUrl/api/user/login');
    final body = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(body),
        headers: {"Content-Type": "application/json"},
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null && data['token'] != null) {
          await storeToken(data['token']);

          final userJson = data['user'];
          User user = User.fromJson(userJson);
          Provider.of<UserProvider>(context, listen: false).setUser(user);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (builder) => Mainscreen(isLoading: true,),
            ),
          );
        } else {
          onError('', 'Unexpected response format.');
        }
      } else {
        final errorData = json.decode(response.body);
        // Display the message from the API response
        String? errorMessage = errorData['message'];
        onError(
          errorMessage != null ? errorMessage : 'Unknown error occurred.',
          '',
        );
      }
    } catch (e) {
      showSnakbar(
        'An error occurred. Check your connection and try again.',
        Colors.red,
        context,
      );
    }
  }

  Future<void> checkEmail(
    String email,
    String username,
    String phone,
    String userType,
    BuildContext context,
    Function(String? emailError) onError,
  ) async {
    final url = Uri.parse('$baseUrl/api/user/email');
    final body = {
      'email': email,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        sendOtp(email, context, username, phone, userType);
      } else {
        onError('Email already exists');
      }
    } catch (e) {
      showSnakbar(
        'An error occurred. Check your connection and try again.',
        Colors.red,
        context,
      );
    }
  }

  Future<void> sendOtp(
    String email,
    BuildContext context,
    String username,
    String phone,
    String userType,
  ) async {
    final url = Uri.parse('$baseUrl/api/user/send/otp');
    final body = {
      'email': email,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (builder) => Otp(
              email: email,
              username: username,
              phone: phone,
              userType: userType,
            ),
          ),
        );
        showSnakbar(
          'Otp send succesfully',
          Colors.green,
          context,
        );
      } else {
        showSnakbar(
          'An error occurred. Try again',
          Colors.red,
          context,
        );
      }
    } catch (e) {
      showSnakbar(
        'An error occurred. Check your connection and try again.',
        Colors.red,
        context,
      );
    }
  }

  Future<void> verifyOtp(
    String email,
    String otp,
    String username,
    String phone,
    String userType,
    BuildContext context,
    Function(String? otpError) onError,
  ) async {
    final url = Uri.parse('$baseUrl/api/user/verify/otp');
    final body = {
      'email': email,
      'otp': otp,
    };

    try {
      final response = await http.post(url, body: json.encode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (builder) => Password(
              email: email,
              name: username,
              phone: phone,
              userType: userType,
            ),
          ),
        );
        showSnakbar(
          'Otp verified succesfully',
          Colors.green,
          context,
        );
      } else {
        final error = json.decode(response.body)['message'] ?? 'Unknown error';
        onError(error);
      }
    } catch (e) {
      showSnakbar(
        'An error occurred. Check your connection and try again.',
        Colors.red,
        context,
      );
    }
  }

  Future<void> signUp(
    String username,
    String phone,
    String email,
    String password,
    String primaryNum,
    String userType,
    BuildContext context,
  ) async {
    final collageId = extractId(email);

    final url = Uri.parse('$baseUrl/api/user/register');
    final body = {
      'username': username,
      'collegeId': collageId,
      'phno': phone,
      'email': email,
      'password': password,
      'primary_sos': primaryNum,
      'userType': userType,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null && data['token'] != null) {
          await storeToken(data['token']);
          final userJson = data['user'];
          User user = User.fromJson(userJson);
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (builder) => Mainscreen( isLoading: true,),
            ),
          );
        } else {
          final error =
              json.decode(response.body)['message'] ?? 'Unknown Error';
          showSnakbar(
            error,
            Colors.red,
            context,
          );
        }
      } else {
        final error = json.decode(response.body)['message'] ?? 'Unknown Error';
        showSnakbar(
          error,
          Colors.red,
          context,
        );
      }
    } catch (e) {
      showSnakbar(
        'An error occurred. Check your connection and try again.',
        Colors.red,
        context,
      );
    }
  }

  Future<void> googleSignUp(
    BuildContext context,
    String userType,
  ) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Attempt Google Sign-In
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      if (user == null) {
        // User canceled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in canceled')),
        );
        return;
      }

      // Use the email and construct the secret
      final email = user.email;
      final secret = email.substring(0, 10);

      if (!isValidEmail(email, userType)) {
        showSnakbar('Please use a valid RGUKT email.', Colors.red, context);
        return;
      }

      // Call your API
      final response = await http.post(
        Uri.parse(
            'https://tech-hackathon-glowhive.onrender.com/api/user/login/google'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "secret": secret}),
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['user'] != null) {
          // Store user details and navigate to the next screen
          User user = User.fromJson(data['user']);
          Provider.of<UserProvider>(context, listen: false).setUser(user);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Mainscreen(isLoading: true,),
            ),
          );
          await googleSignIn.signOut();
        } else {
          showSnakbar('Unexpected response format', Colors.red, context);
          await googleSignIn.signOut();
        }
      } else {
        showSnakbar('Account does not exit for this email..Please register',
            Colors.red, context);
        await googleSignIn.signOut();
      }
    } catch (error) {
      showSnakbar('An error occurred: $error', Colors.red, context);
      print(error);
      await googleSignIn.signOut();
    }
  }
}
