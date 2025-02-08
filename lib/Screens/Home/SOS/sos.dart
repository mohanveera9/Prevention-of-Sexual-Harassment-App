import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:posh/Model/connectivity_wrapper.dart';
import 'package:posh/Model/userModel/userModel.dart';
import 'package:posh/Screens/Home/SOS/FakeCall/call.dart';
import 'package:posh/Screens/Home/SOS/VideoRecorder.dart';
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

class _SosState extends State<Sos>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;
  bool isLoading = false;
  String _lat = '';
  String _lag = '';
  bool _isWaitingForSettings = false; // Add this flag

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getLive();
    _getLiveLocation();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

//for live ture or false
  Future<bool> getLive() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      ShowSnackbar().showSnackbar('Turn on location', Colors.red, context);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ShowSnackbar()
            .showSnackbar('Please allow location', Colors.red, context);
        return false;
      }
    }

    return true;
  }

  //Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //for live Location
  Future<void> _getLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        ShowSnackbar().showSnackbar('Trun on location', Colors.red, context);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        ShowSnackbar()
            .showSnackbar('Please allow location', Colors.red, context);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        ShowSnackbar()
            .showSnackbar('Please allow location', Colors.red, context);
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
      ShowSnackbar().showSnackbar('No internet...', Colors.red, context);
    }
  }

  //SendLoaction
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
        ShowSnackbar()
            .showSnackbar('Location Sent Successfully', Colors.green, context);
      } else {
        ShowSnackbar().showSnackbar(
            'Error occurred, Please try again', Colors.red, context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }
      ShowSnackbar()
          .showSnackbar('Check your internet connection', Colors.red, context);
    }
  }

  //Pop pup for counter

  Timer? _countdownTimer;
  int _countdown = 3;
//for video
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

//for location
  void _showCountdownDialog1(
      BuildContext context, String lat, String lag, String text) {
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
                    _showSendingDialog(context);
                    sendLocation(lat, lag);
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

//after location
  void _showSendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sending Location...',
            style: TextStyle(fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

// Check and request audio permission for fake call
  Future<bool> checkAudioPermission(BuildContext context) async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      status = await Permission.microphone.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, "Microphone");
      return false;
    }
    return false;
  }

// Check and request camera permission for video recording
  Future<bool> checkCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, "Camera");
      return false;
    }
    return false;
  }

// Show settings dialog if permission is permanently denied
  void _showSettingsDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
            'This feature requires access to your $permissionType. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              setState(() {
                _isWaitingForSettings = true; // Set the flag
              });
              await openAppSettings(); // Open app settings
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForSettings) {
      // User returned from settings
      setState(() {
        _isWaitingForSettings = false; // Reset the flag
      });
      checkPermissionsAndUpdateUI(); // Check permissions and update UI
    }
  }

  void checkPermissionsAndUpdateUI() async {
   setState(() {
     
   });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final name = "Fam";
    final phno = userModel.primary;
    final name1 = userModel.name;

    return ConnectivityWrapper(
      child: Scaffold(
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
                                  onTap: () async {
                                    if (await getLive()) {
                                      _showCountdownDialog1(context, _lat, _lag,
                                          "Send you location in");
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
                                              color:
                                                  Colors.red.withOpacity(0.5),
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                onTap: () async {
                                  if (await checkCameraPermission(context)) {
                                    _showCountdownDialog(context, () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (builder) =>
                                              VideoRecorderScreen(),
                                        ),
                                      );
                                    }, 'Video recording started in');
                                  }
                                },
                                context: context,
                              ),
                              SosButton(
                                icon: Icons.call,
                                label: 'Audio\nCall',
                                onTap: () async {
                                  if (await checkAudioPermission(context)) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (builder) => CallScreen(
                                          name: name,
                                          phno: phno,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                context: context,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Note:\n\n1. Enabling location access is crucial for sending accurate emergency alerts. Please ensure that your location services are turned on.\n\n',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                TextSpan(
                                  text:
                                      '2. Audio call functionality is only available when you grant permission for microphone access.\n\n',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                TextSpan(
                                  text:
                                      '3. Video call functionality requires camera access. Please enable camera permissions for a seamless experience.\n\n',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                TextSpan(
                                  text:
                                      '4. If you denied any of the necessary permissions, kindly go to the app settings allow permissions \n\n',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
