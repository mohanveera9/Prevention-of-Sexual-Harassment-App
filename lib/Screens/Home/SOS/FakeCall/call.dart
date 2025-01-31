import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:posh/Screens/Home/SOS/FakeCall/mainCall.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String phno;

  const CallScreen({super.key, required this.name, required this.phno});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
    _autoPopAfterDelay();
  }

  // Play ringtone
  Future<void> _playRingtone() async {
    await _audioPlayer.play(AssetSource('img/ringtone.mp3'),
        volume: 100.0); // Ensure the 'ringtone.mp3' is added to assets
  }

  // Stop the ringtone when leaving the screen
  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  // Auto pop after 30 seconds
  void _autoPopAfterDelay() {
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
         _audioPlayer.stop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (builder) =>
                Maincall(name: widget.name, phoneNumber: widget.phno),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6BF3DD),
              Color(0xFF39D0D1),
              Color.fromARGB(255, 30, 123, 179),
              Color(0xFF0C3F9E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange.shade700,
                    child: Text(
                      widget.name.isNotEmpty
                          ? widget.name[0].toUpperCase()
                          : "?",
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '+91 ${widget.phno}  India',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_off),
                        color: Colors.white,
                        iconSize: 30,
                        onPressed: () {},
                      ),
                      const Text(
                        'Mute',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.message),
                        color: Colors.white,
                        iconSize: 30,
                        onPressed: () {},
                      ),
                      const Text(
                        'Message',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Manually end the call
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _audioPlayer.stop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (builder) =>
                              Maincall(name: widget.name, phoneNumber: widget.phno),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
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
}
