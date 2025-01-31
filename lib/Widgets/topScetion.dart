import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TopSection extends StatefulWidget {
  final String username;

  const TopSection({super.key, required this.username});

  @override
  _TopSectionState createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> {
  String _location = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
  }

  Future<void> _getLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = "Tap to turn on";
        });
         await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Tap to allow";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Tap to allow";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _location =
            "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
    } catch (e) {
      setState(() {
        _location = "Error Occur";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            right: 30,
            bottom: 20,
            top: 40,
          ),
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
                    widget.username,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      if (_location == 'Tap to turn on') {
                        await Geolocator.openLocationSettings();
                        _getLiveLocation();
                      }
                      if (_location == 'Tap to allow') {
                        await Geolocator.requestPermission();
                        _getLiveLocation();
                      }
                    },
                    child: Text(
                      _location,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
