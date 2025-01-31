import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:posh/Model/DataProvider.dart';
import 'package:posh/Model/LocationModel.dart';
import 'package:posh/Model/userModel/user.dart';
import 'package:posh/Model/userModel/userModel.dart';
import 'package:posh/Model/userProvider.dart';
import 'package:posh/Screens/Home/Home.dart';
import 'package:posh/Screens/Home/HomeShimmer.dart';
import 'package:posh/Screens/Home/SOS/sos.dart';
import 'package:posh/Screens/Home/profile.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Mainscreen extends StatefulWidget {
  final bool isLoading;
  const Mainscreen({super.key, required this.isLoading});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int currentPage = 1;
  bool isLoadingUser = false;
  final PageController _pageController = PageController();

  final List<Widget> pages = [Home(), Sos(), Profile()];

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    // Handle permission results
    if (statuses[Permission.microphone]?.isDenied ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission denied.')),
      );
    }

    if (statuses[Permission.camera]?.isDenied ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission denied.')),
      );
    }
  }

  Future<void> fetchAndSetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Provider.of<Locationmodel>(context, listen: false).SetLocation(
        lat: '0.0',
        lag: '0.0',
        status: false,
        message: 'Location services are disabled.',
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Provider.of<Locationmodel>(context, listen: false).SetLocation(
          lat: '0.0',
          lag: '0.0',
          status: false,
          message: 'Location permission denied.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Provider.of<Locationmodel>(context, listen: false).SetLocation(
        lat: '0.0',
        lag: '0.0',
        status: false,
        message: 'Location permissions are permanently denied.',
      );
      return;
    }

    // Get the current location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Provider.of<Locationmodel>(context, listen: false).SetLocation(
        lat: position.latitude.toString(),
        lag: position.longitude.toString(),
        status: true,
        message: 'Location fetched successfully.',
      );
    } catch (e) {
      Provider.of<Locationmodel>(context, listen: false).SetLocation(
        lat: '0.0',
        lag: '0.0',
        status: false,
        message: 'Error fetching location',
      );
    }
  }

  Future<void> fetchUser() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('https://tech-hackathon-glowhive.onrender.com/api/user/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userJson = data['user'];

        // Parse user data and store it in UserProvider
        User user = User.fromJson(userJson);
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (userProvider.user != null) {
        Provider.of<UserModel>(context, listen: false).setUserDetails(
          name: userProvider.user!.username,
          primary: userProvider.user!.primarySos,
        );
      }

      } else {
        ShowSnakbar().showSnackbar(
          'An error occurred. Check your connection and try again.',
          Colors.red,
          context,
        );
      }
    } catch (e) {
      ShowSnakbar().showSnackbar(
        'An error occurred. Check your connection and try again.',
        Colors.red,
        context,
      );
    }
  }

  Future<void> fetchUserWithShimmer() async {
    setState(() => isLoadingUser = true); // Show shimmer effect

    await fetchUser(); // Fetch user details

    setState(() => isLoadingUser = false); // Hide shimmer effect
  }

  @override
  void initState() {
    super.initState();

    // Fetch and set initial location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAndSetLocation();
      requestPermissions();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await getToken();
      if (token != null) {
        // Set the token in the DataProvider
        Provider.of<DataProvider>(context, listen: false).setToken(token);

        // Fetch data using the token
        Provider.of<DataProvider>(context, listen: false).fetchData();
      }
    });

    if (!widget.isLoading) {
      fetchUserWithShimmer();
    } else {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        Provider.of<UserModel>(context, listen: false).setUserDetails(
          name: userProvider.user!.username,
          primary: userProvider.user!.primarySos,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: isLoadingUser
          ? HomeShimmer()
          : PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: pages,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        shape: CircleBorder(),
        onPressed: () {
          _pageController.jumpToPage(1);
          setState(() {
            currentPage = 1;
          });
        },
        child: Icon(
          Icons.sos,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(horizontal: 45),
        surfaceTintColor: Colors.transparent,
        height: 60,
        color: Color.fromARGB(255, 30, 123, 179),
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _pageController.jumpToPage(0);
                setState(() {
                  currentPage = 0;
                });
              },
              icon: Icon(
                Icons.home,
                color: currentPage == 0 ? Colors.white : Colors.white70,
              ),
            ),
            IconButton(
              onPressed: () {
                _pageController.jumpToPage(2);
                setState(() {
                  currentPage = 2;
                });
              },
              icon: Icon(
                Icons.person,
                color: currentPage == 2 ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}