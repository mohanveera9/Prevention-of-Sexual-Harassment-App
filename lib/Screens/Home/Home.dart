import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:posh/Model/userModel/userModel.dart';
import 'package:posh/Model/userProvider.dart';
import 'package:posh/Screens/Home/HomeShimmer.dart';
import 'package:posh/Screens/Home/SOS/emergency.dart';
import 'package:posh/Screens/Home/complaint.dart';
import 'package:posh/Screens/Home/status.dart';
import 'package:posh/Widgets/quickactionbutton.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:posh/Widgets/topScetion.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _countdownTimer;
  int _countdown = 3;
  String _lat = '';
  String _lag = '';
  Timer? _locationTimer;

  void _showCountdownDialog(BuildContext context, String lat, String lag) {
    _countdown = 3; // Reset the countdown every time the dialog is opened
    bool isDialogActive = true; // Track dialog state

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Start the countdown
            _countdownTimer =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              if (isDialogActive) {
                setDialogState(() {
                  if (_countdown > 1) {
                    _countdown--;
                  } else {
                    _countdownTimer?.cancel();
                    isDialogActive = false;
                    Navigator.of(context).pop(); // Close countdown dialog
                    _showSendingDialog(context); // Show sending dialog
                    sendLocation(lat, lag); // Send location
                  }
                });
              }
            });

            return AlertDialog(
              title: const Text('Emergency Alert'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sending your location in $_countdown...', // Countdown updated here
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _countdownTimer?.cancel(); // Cancel the countdown
                    isDialogActive = false; // Mark dialog as closed
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Ensure the timer is canceled if the dialog is closed externally
      isDialogActive = false;
      _countdownTimer?.cancel();
    });
  }

  void _showSendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sending Location...',
            style: TextStyle(
              fontSize: 20
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 10,)
            ],
          ),
        );
      },
    );
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> sendLocation(String lat, String lag) async {
    final url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');
    final token = await getToken();

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "location": [lat, lag],
        }),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }

      if (response.statusCode == 200) {
        ShowSnakbar()
            .showSnackbar('Location Sent Successfully', Colors.green, context);
      } else {
        ShowSnakbar().showSnackbar(
            'Error occurred, Please try again', Colors.red, context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }
      ShowSnakbar()
          .showSnackbar('Check your internet connection', Colors.red, context);
    }
  }

  Future<void> _getLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        ShowSnakbar().showSnackbar('Trun on location', Colors.red, context);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        ShowSnakbar().showSnackbar('Allow location', Colors.red, context);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        ShowSnakbar().showSnackbar('Allow location', Colors.red, context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _lat = position.latitude.toString();
        _lag = position.longitude.toString();
      });
    } catch (e) {
      ShowSnakbar().showSnackbar('No internet...', Colors.red, context);
    }
  }

  Future<bool> getLive() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      ShowSnakbar().showSnackbar('Turn on location', Colors.red, context);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ShowSnakbar().showSnackbar('Allow location', Colors.red, context);
        return false;
      }
    }

    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLiveLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getLiveLocation();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Cancel timer if widget is disposed
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final name = userModel.name;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final uID = user?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopSection(username: name),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          HomeShimmer();
                        },
                        child: Text(
                          'Emergency help Needed?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (await getLive()) {
                                _showCountdownDialog(context, _lat, _lag);
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 2,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  'assets/img/wifi.png',
                                  height: 60,
                                  width: 60,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Press the button to send location',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      children: [
                        Quickactionbutton(
                            icon: Icons.feedback,
                            label: 'File a\nComplaint',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (builder) =>
                                      Complaint(id: uID ?? ''),
                                ),
                              );
                            },
                            context: context),
                        Quickactionbutton(
                            icon: Icons.library_books_outlined,
                            label: 'Complaint\nHistory',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (builder) => Status(),
                                ),
                              );
                            },
                            context: context),
                        Quickactionbutton(
                          icon: Icons.emergency,
                          label: 'Emergency\nContacts',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => Emergency(),
                              ),
                            );
                          },
                          context: context,
                        ),
                        Quickactionbutton(
                          icon: Icons.call,
                          label: 'Women\nHelpline',
                          onTap: () {
                            launch('tel:181');
                          },
                          context: context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
