import 'package:flutter/material.dart';
import 'package:posh/Model/DataProvider.dart';
import 'package:posh/Model/LocationModel.dart';
import 'package:posh/Model/userModel/userModel.dart';
import 'package:posh/Model/userProvider.dart';
import 'package:posh/Screens/Home/HomeShimmer.dart';
import 'package:posh/Screens/Home/mainScreen.dart';
import 'package:posh/Screens/Login/loginMain.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (context) => DataProvider()),
        ChangeNotifierProvider(create: (context) => Locationmodel())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prevention of Sexual Harassment App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 30, 123, 179),
          primary: Color.fromARGB(255, 30, 123, 179),
          secondary: Color(0xFF39D0D1),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashHandler(),
    );
  }
}

class SplashHandler extends StatefulWidget {
  const SplashHandler({super.key});

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  @override
  void initState() {
    super.initState();
    _showSplash();
  }

  Future<void> _showSplash() async {
    // Show splash screen for a minimum of 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Proceed with checking the token and navigation after the delay
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    try {
      String? token = await _getToken();

      if (token == null) {
        _navigateToLogin();
        return;
      }

      _navigateToHome();
    } catch (e) {
      print('Error verifying token: $e');
      _navigateToLogin();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginmain()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Mainscreen(isLoading: false,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6BF3DD), // Start color
              Color(0xFF39D0D1), // Midpoint color
              Color(0xFF0C3F9E), // End color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Image.asset('assets/img/mainicon.png'),
        ),
      ),
    );
  }
}
