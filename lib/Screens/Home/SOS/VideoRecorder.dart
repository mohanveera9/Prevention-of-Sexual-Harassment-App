import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:posh/Model/connectivity_wrapper.dart';
import 'package:posh/Screens/Home/mainScreen.dart';
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
      ShowSnackbar().showSnackbar('No internet...', Colors.red, context);
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
          _showMessage('No cameras available on this device.', Colors.red);
        }
      } catch (e) {
        _showMessage('Error initializing cameras: $e', Colors.red);
      }
    } else {
      _showMessage('Camera permission denied.', Colors.red);
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showMessage('Camera permission denied. Please enable it in settings.',
          Colors.red);
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
      _showMessage('Error initializing camera: $e', Colors.red);
      Navigator.pop(context);
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _showMessage('Camera is not initialized.', Colors.red);
      Navigator.pop(context);
      return;
    }

    if (_controller!.value.isRecordingVideo) {
      _showMessage('Already recording.', Colors.red);
      Navigator.pop(context);
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _showMessage('Video recording started.', Colors.green);
      _startTimer();
    } catch (e) {
      _showMessage('Error starting video recording: $e', Colors.red);
      Navigator.pop(context);
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      _showMessage('No video recording in progress.', Colors.red);
      return;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      print('Video recorded to: ${videoFile.path}');

      // Upload the video to Cloudinary
      _showSendingDialog(context);
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

  void _showSendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sending Video...',
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
        _showMessage('Error occurd', Colors.red);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error uploading video: $e');
      _showMessage("check your interent connection", Colors.red);
      Navigator.pop(context);
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
      print(body);
      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ShowSnackbar()
            .showSnackbar('Audio Sent Successfully', Colors.green, context);
      } else {
        ShowSnackbar().showSnackbar(
            'Failed to send Video & Location', Colors.red, context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the sending dialog
      }
      ShowSnackbar().showSnackbar('Error occurred', Colors.red, context);
    } finally {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (builder) => Mainscreen(isLoading: true,),
        ),
      );
    }
  }

  void _showMessage(String message, Color color) {
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
      child: ConnectivityWrapper(
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
                        onPressed: () {},
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
