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
  bool hasError = false;
  final PageController _pageController = PageController();
  final List<Widget> pages = [Home(), Sos(), Profile()];

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchUser() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('https://tech-hackathon-glowhive.onrender.com/api/user/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userJson = data['user'];
        User user = User.fromJson(userJson);
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Provider.of<UserModel>(context, listen: false).setUserDetails(
          name: user.username,
          primary: user.primarySos,
        );
        setState(() => hasError = false);
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }
  }

  Future<void> fetchUserWithShimmer() async {
    setState(() {
      isLoadingUser = true;
      hasError = false;
    });
    await fetchUser();
    setState(() => isLoadingUser = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserWithShimmer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: isLoadingUser
          ? HomeShimmer()
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'An error occurred. Please try again.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchUserWithShimmer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  children: pages,
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        shape: CircleBorder(),
        onPressed: () {
          _pageController.jumpToPage(1);
          setState(() => currentPage = 1);
        },
        child: Icon(Icons.sos, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(horizontal: 45),
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
                setState(() => currentPage = 0);
              },
              icon: Icon(
                Icons.home,
                color: currentPage == 0 ? Colors.white : Colors.white70,
              ),
            ),
            IconButton(
              onPressed: () {
                _pageController.jumpToPage(2);
                setState(() => currentPage = 2);
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
