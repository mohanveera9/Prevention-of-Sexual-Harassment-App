import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:posh/Model/connectivity_wrapper.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:record/record.dart'; // Add record package for audio recording
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class Maincall extends StatefulWidget {
  final String name;
  final String phoneNumber;

  const Maincall({super.key, required this.name, required this.phoneNumber});

  @override
  State<Maincall> createState() => _MaincallState();
}

class _MaincallState extends State<Maincall> {
  final AudioRecorder audioRecorder = AudioRecorder();
  Timer? _timer;
  int _secondsElapsed = 0;
  bool isRecording = false;
  String? recordingPath;
  bool isLoading = false;
  String _lat = "";
  String _lag = "";

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
    _startAudioRecording();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    audioRecorder.stop();
    super.dispose();
  }

  //Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //Location
  Future<void> _getLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
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

  // Start recording audio
  void _startAudioRecording() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, 'recording.mp3');

      await audioRecorder.start(RecordConfig(), path: filePath);

      setState(() {
        isRecording = true;
        recordingPath = filePath;
      });

      Future.delayed(Duration(seconds: 15), () async {
        if (isRecording) {
          String? path = await audioRecorder.stop();
          setState(() {
            isRecording = false;
            recordingPath = path;
          });
          File audioFile = File(recordingPath!);
          _showSendingDialog(context);
          _uploadAudioToCloudinary(audioFile);
        }
      });
    }
  }

  // Timer for real-time updates
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<String?> _uploadAudioToCloudinary(File audioFile) async {
    const String uploadPreset = 'my_preset';
    const String uploadUrl =
        'https://api.cloudinary.com/v1_1/duo4ymk7n/video/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files
          .add(await http.MultipartFile.fromPath('file', audioFile.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        final secureUrl = jsonResponse['secure_url'] as String;
        print('Uploaded Audio URL: $secureUrl');
        // Optionally, send the audio URL along with the location data
        _sendLocationToApi(_lat, _lag, secureUrl);
      } else {
        print('Upload failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading audio: $e');
    }
    return null;
  }

  //Send Loaction and audio
  Future<void> _sendLocationToApi(
      String latitude, String longitude, String path) async {
    final token = await getToken();
    var url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');

    try {
      // Create the request body
      final body = jsonEncode({
        "location": [latitude, longitude], // Send location as a JSON array
        "audioLink": path,
      });

      // Make a POST request
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }
      if (response.statusCode == 200) {
        ShowSnackbar()
            .showSnackbar('Audio Sent Successfully', Colors.green, context);
        print(response.body);
      } else {
        ShowSnackbar().showSnackbar(
            'Failed to send Audio & Location', Colors.red, context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }
      ShowSnackbar().showSnackbar('Error occurred', Colors.red, context);
    } finally {
      _cleanupRecordingFile(); // Cleanup the recording file
    }
  }

//Clean The audio
  void _cleanupRecordingFile() {
    if (recordingPath != null) {
      final file = File(recordingPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  void _showSendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sending Audio...',
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _secondsElapsed >= 20;
      },
      child: ConnectivityWrapper(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6BF3DD),
                  Color(0xFF39D0D1),
                  Color.fromARGB(255, 30, 123, 179),
                  Color(0xFF0C3F9E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Spacer(),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.shade700,
                  child: Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "?",
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+91 ${widget.phoneNumber}  India',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_secondsElapsed),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const Spacer(flex: 2),
                GridView(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  children: [
                    _buildCallOption(Icons.mic_off, "Mute"),
                    _buildCallOption(Icons.pause, "Hold"),
                    _buildCallOption(Icons.add_call, "Add call"),
                    _buildCallOption(Icons.videocam, "Video"),
                    _buildCallOption(Icons.voicemail, "Record"),
                    _buildCallOption(Icons.speaker, "Speaker"),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _secondsElapsed >= 20
                          ? () {
                              Navigator.of(context).pop();
                            }
                          : () {}, // Disable tap event if `_secondsElapsed` < 20
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallOption(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }
}
