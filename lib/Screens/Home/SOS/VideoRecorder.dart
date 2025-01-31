import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:posh/Screens/Home/SOS/sos.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoRecorderScreen extends StatefulWidget {
  @override
  _VideoRecorderScreenState createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _timerValue = 10;
  bool _isRecording = false;
  bool isLoading = false;
  int _secondsElapsed = 0;
  String _lag = "";
  String _lat = "";

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
    _initializeCameras();
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
      ShowSnakbar().showSnackbar('No internet...', Colors.red, context);
    }
  }

  //Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _initializeCameras() async {
    if (await _requestPermissions()) {
      try {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          _initializeCameraController(_cameras[0]);
        } else {
          _showMessage('No cameras available on this device.');
        }
      } catch (e) {
        _showMessage('Error initializing cameras: $e');
      }
    } else {
      _showMessage('Camera permission denied.');
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showMessage('Camera permission denied. Please enable it in settings.');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  void _initializeCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    try {
      await cameraController.initialize();
      setState(() {
        _controller = cameraController;
      });
      _startRecording();
    } catch (e) {
      _showMessage('Error initializing camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _showMessage('Camera is not initialized.');
      return;
    }

    if (_controller!.value.isRecordingVideo) {
      _showMessage('Already recording.');
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _showMessage('Video recording started.');
      _startTimer();
    } catch (e) {
      _showMessage('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      _showMessage('No video recording in progress.');
      return;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      print('Video recorded to: ${videoFile.path}');

      // Upload the video to Cloudinary
      final cloudinaryUrl =
          await _uploadVideoToCloudinary(File(videoFile.path));
      if (cloudinaryUrl != null) {
        print('Cloudinary Video URL: $cloudinaryUrl');
      } else {
        print('Failed to upload video.');
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  Future<String?> _uploadVideoToCloudinary(File videoFile) async {
    const String cloudName = 'duo4ymk7n';

    const String uploadPreset = 'my_preset'; // Replace with your upload preset
    const String uploadUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/video/upload';
    setState(() {
      isLoading = true;
    });
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add upload preset
      request.fields['upload_preset'] = uploadPreset;

      // Add the video file to the request
      request.files
          .add(await http.MultipartFile.fromPath('file', videoFile.path));

      // Send the request
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        final secureUrl = jsonResponse['secure_url'] as String;
        print('Uploaded Video URL: $secureUrl');
        _sendLocationToApi(_lat, _lag, secureUrl);
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Upload failed with response: $responseBody');
        _showMessage('Error occurd');
      }
    } catch (e) {
      print('Error uploading video: $e');
      _showMessage("check your interent connection");
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return null;
  }

  //Send Loaction and audio
  Future<void> _sendLocationToApi(
      String latitude, String longitude, String path) async {
    if (!mounted) return; // Ensure widget is still mounted
    final token = await getToken();
    var url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');

    try {
      _showPopup("Sending Video and Location...", autoClose: false);
      final body = jsonEncode({
        "location": [latitude, longitude],
        "videoLink": path,
      });
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (!mounted) return; // Check again after async operation

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        _showPopup("Video & Location sent successfully!", autoClose: true);
      } else {
        final responseBody = jsonDecode(response.body);
        _showPopup("Failed to send Video & Location", autoClose: true);
      }
    } catch (e) {
      if (!mounted) return; // Check again after async operation
      _showPopup("Error occurred", autoClose: true);
    }
  }

//Pop up for Loaction
  _showPopup(String message, {bool autoClose = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (autoClose) {
          Future.delayed(Duration(seconds: 2), () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              if (message == 'Video & Location sent successfully!' ||
                  message == "Failed to send Video & Location" ||
                  message == 'Error occurred') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (builder) => Sos(),
                  ),
                );
              }
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
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _isRecording && _timerValue > 0) {
        setState(() {
          _timerValue--;
        });
        _startTimer();
      } else if (mounted && _timerValue == 0) {
        _stopRecording();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _secondsElapsed >= 20;
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (_controller != null && _controller!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(_controller!),
              ),

            // Display the recording timer and status
            if (_isRecording)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Video Recording:  ${10 - _timerValue} sec',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      onPressed: _stopRecording,
                      icon: Icon(
                        Icons.stop_circle,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isRecording = false; // Stop any ongoing recording
    super.dispose();
  }
}
