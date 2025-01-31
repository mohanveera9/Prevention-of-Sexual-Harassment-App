import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:posh/Model/userModel/userModel.dart';
import 'package:posh/Screens/Home/SOS/FakeCall/call.dart';
import 'package:posh/Screens/Home/SOS/VideoRecorder.dart';
import 'package:posh/Screens/Home/SOS/soshelp.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:posh/Widgets/sos_button.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sos extends StatefulWidget {
  const Sos({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SosState createState() => _SosState();
}

class _SosState extends State<Sos> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getLive();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  Future<void> getLive() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      ShowSnakbar().showSnackbar('Turn on location', Colors.red, context);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ShowSnakbar().showSnackbar('Allow location', Colors.red, context);
        return;
      }
    }
  }


  //Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //Location
  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }
    return await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //SendLoaction
  Future<void> _sendLocation(double latitude, double longitude) async {
    final token = await getToken();
    var url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');

    try {
      // Show "Location is sending..." dialog
      _showPopup("Location is sending...");

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "location": [latitude, longitude],
        }),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Close the popup
      print(response.body);
      if (response.statusCode == 200) {
        _showPopup("Location sent successfully!", autoClose: true);
      } else {
        _showPopup("Failed to send location: ${response.statusCode}");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Close the popup in case of error
      _showPopup("Error occurred: $e");
    } finally {}
  }

  //Pop up for Loaction
  _showPopup(String message, {bool autoClose = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (autoClose) {
          Future.delayed(Duration(seconds: 2), () {
            // ignore: use_build_context_synchronously
            if (Navigator.canPop(context)) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }
          });
        }
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        );
      },
    );
  } //Pop pup for counter

  void _showCountdownPopup(VoidCallback onConfirm) {
    int countdown = 3;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Start the timer when the dialog is created
            timer ??= Timer.periodic(Duration(seconds: 1), (timer) {
              if (countdown == 1) {
                timer.cancel();
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext); // Close the popup safely
                }
                onConfirm(); // Trigger the confirmation callback
              } else {
                setState(() {
                  countdown--;
                });
              }
            });
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Countdown
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  IconButton(
                    onPressed: () {
                      timer?.cancel(); // Cancel the timer
                      if (Navigator.canPop(dialogContext)) {
                        Navigator.pop(dialogContext); // Close the dialog safely
                      }
                      // Stop recording audio if recording
                      if (isRecording) {
                        audioRecorder.stop();
                        setState(() {
                          isRecording = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Ensure timer is canceled when the dialog is dismissed
      timer?.cancel();
    });
  }

  Timer? _countdownTimer;
  int _countdown = 3;

  void _showCountdownDialog(
      BuildContext context, VoidCallback onConfirm, String text) {
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
                    isDialogActive = false; // Mark dialog as closed
                    Navigator.of(context).pop(); // Close the dialog
                    onConfirm(); // Perform the desired task
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
                    '$text $_countdown...', // Countdown updated here
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

  void _performEmergencyTask() {
    ShowSnakbar().showSnackbar('message', Colors.green, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final name = "Fam";
    final phno = userModel.primary;
    final name1 = userModel.name;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          name1,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6BF3DD), // Start color
                            Color(0xFF39D0D1), // Midpoint color
                            Color(0xFF39D0D1),
                            Color(0xFF0C3F9E),
                            Color(0xFF0C3F9E), // End color
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/img/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
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
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showCountdownDialog(
                                  context,
                                  _performEmergencyTask,
                                  'Send your location in'
                                ),
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
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
                            SosButton(
                              icon: Icons.video_camera_back,
                              label: 'Video\nRecording',
                              onTap: () {
                                _showCountdownDialog(context, () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (builder) =>
                                          VideoRecorderScreen(),
                                    ),
                                  );
                                },
                                'Video recording started in'
                                );
                              },
                              context: context,
                            ),
                            SosButton(
                              icon: Icons.call,
                              label: 'Audio\nCall',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (builder) => CallScreen(
                                      name: name,
                                      phno: phno,
                                    ),
                                  ),
                                );
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
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => Soshelp(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
