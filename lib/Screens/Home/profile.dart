import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posh/Model/userModel/userModel.dart';
import 'package:posh/Model/userProvider.dart';
import 'package:posh/Screens/Login/loginMain.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isEditingName = false;
  bool _isEditingSos = false;
  bool _isLoadingName = false;
  bool _isLoadingSos = false;
  late TextEditingController _nameController;
  late TextEditingController _primaryController;
  String _lat = '';
  String _lag = '';

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
    final userModel = Provider.of<UserModel>(context, listen: false);
    _nameController = TextEditingController(text: userModel.name);
    _primaryController = TextEditingController(text: userModel.primary);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _primaryController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> editName({required String name}) async {
    if (name.isEmpty) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _nameController.text = userModel.name;
      ShowSnakbar()
          .showSnackbar('Username cannot be empty.', Colors.red, context);

      return;
    }

    final token = await getToken();
    final url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/edit/username');
    final body = {"username": name};

    setState(() {
      _isLoadingName = true;
    });

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 &&
          responseData['message'] == "User Updated Successfully") {
        final userModel = Provider.of<UserModel>(context, listen: false);
        userModel.updateName(name);
        _nameController.text = name; // Update the text controller
        ShowSnakbar()
            .showSnackbar('Name updated successfully.', Colors.green, context);
      } else {
        final userModel = Provider.of<UserModel>(context, listen: false);
        _nameController.text = userModel.name;
        ShowSnakbar()
            .showSnackbar('Failed to update name.', Colors.red, context);
      }
    } catch (e) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _nameController.text = userModel.name;
      ShowSnakbar().showSnackbar(
          'An error occurred. Check your connection and try again.',
          Colors.red,
          context);
    } finally {
      setState(() {
        _isLoadingName = false;
      });
    }
  }

  Future<void> editPrimaryNumber({required String number}) async {
    if (number.isEmpty) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _primaryController.text = userModel.primary;
      ShowSnakbar()
          .showSnackbar('Primary Number cannot be empty.', Colors.red, context);
      return;
    }

    if (number.length != 10) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _primaryController.text = userModel.primary;
      ShowSnakbar()
          .showSnackbar('Enter a valid 10-digit number.', Colors.red, context);
      return;
    }

    final regEx = RegExp(r'^\d{10}$');
    if (!regEx.hasMatch(number)) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _primaryController.text = userModel.primary;
      ShowSnakbar()
          .showSnackbar('Enter a valid 10-digit number.', Colors.red, context);
      return;
    }

    final token = await getToken();
    final url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/edit/primary');
    final body = {"primary_sos": number};

    setState(() {
      _isLoadingSos = true;
    });

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final userModel = Provider.of<UserModel>(context, listen: false);
        userModel.updateNumber(number);
        _primaryController.text = number; // Update the text controller
        ShowSnakbar().showSnackbar(
            'Primary SOS updated successfully.', Colors.green, context);
      } else {
        final userModel = Provider.of<UserModel>(context, listen: false);
        _primaryController.text = userModel.primary;
        ShowSnakbar()
            .showSnackbar('Failed to update Primary SOS.', Colors.red, context);
      }
    } catch (e) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _primaryController.text = userModel.primary;
      ShowSnakbar().showSnackbar(
          'An error occurred. Check your connection and try again.',
          Colors.red,
          context);
    } finally {
      setState(() {
        _isLoadingSos = false;
      });
    }
  }

  Color _getColorForCharacter(String name) {
    // Define a list of colors
    const List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
      Colors.deepPurple,
      Colors.indigo,
      Colors.lime,
      Colors.pink,
      Colors.yellow,
      Colors.brown,
    ];

    if (name.isEmpty) {
      return Colors.grey;
    }

    final char = name[0].toUpperCase();
    final index = char.codeUnitAt(0) % colors.length;
    return colors[index];
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
        ShowSnakbar()
            .showSnackbar('Please allow location', Colors.red, context);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        ShowSnakbar()
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
      ShowSnakbar().showSnackbar('No internet...', Colors.red, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final name = userModel.name;

    final userType = user != null ? user.userType : 'user';
    var user_type = 'Student';

    if (userType == 'staff') {
      setState(() {
        user_type = 'Staff';
      });
    } else {
      setState(() {
        user_type = 'Student';
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/img/header1.svg',
                  fit: BoxFit.cover,
                ),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: _getColorForCharacter(name),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'M',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6BF3DD),
                                Color(0xFF39D0D1),
                                Color(0xFF0C3F9E),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 30, right: 30),
                  child: Column(
                    children: [
                      _buildEditableProfileField(
                        icon: Icons.person,
                        label: 'Name',
                        isNumber: false,
                        controller: _nameController,
                        isEditable: _isEditingName,
                        isLoading: _isLoadingName,
                        onEditPressed: () {
                          if (_isEditingName && !_isLoadingName) {
                            editName(name: _nameController.text);
                          }
                          setState(() {
                            _isEditingName = !_isEditingName;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildEditableProfileField(
                        icon: Icons.sos,
                        label: 'Primary SOS',
                        isNumber: true,
                        controller: _primaryController,
                        isEditable: _isEditingSos,
                        isLoading: _isLoadingSos,
                        onEditPressed: () {
                          if (_isEditingSos && !_isLoadingSos) {
                            editPrimaryNumber(number: _primaryController.text);
                          }
                          setState(() {
                            _isEditingSos = !_isEditingSos;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildProfileField(
                        icon: Icons.email,
                        label: 'Email',
                        value:
                            user != null ? user.email : 'n210770@rguktn.ac.in',
                      ),
                      const SizedBox(height: 30),
                      _buildProfileField(
                        icon: Icons.call,
                        label: 'Mobile Number',
                        value: user != null ? user.phone : '9502774125',
                      ),
                      const SizedBox(height: 30),
                      _buildProfileField(
                        icon: Icons.group,
                        label: 'User Type',
                        value: user_type,
                      ),
                      const SizedBox(height: 30),
                      _buildSignOutButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableProfileField(
      {required IconData icon,
      required String label,
      required TextEditingController controller,
      required bool isEditable,
      required bool isLoading,
      required VoidCallback onEditPressed,
      required bool isNumber}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color.fromARGB(255, 30, 123, 179),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              isEditable
                  ? TextField(
                      controller: controller,
                      keyboardType:
                          isNumber ? TextInputType.number : TextInputType.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      controller.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onEditPressed,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color.fromARGB(255, 30, 123, 179),
                  ),
                )
              : Icon(
                  isEditable ? Icons.check : Icons.edit,
                  color: Color.fromARGB(255, 30, 123, 179),
                ),
        ),
      ],
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color.fromARGB(255, 30, 123, 179),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 30, 123, 179),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
          // Clear the token from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Loginmain()),
            (route) => false,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
