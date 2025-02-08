import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:posh/Model/ConnectivityProvider.dart';
import 'package:posh/Widgets/show_snakbar.dart';
import 'package:provider/provider.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  ConnectivityResult? _previousStatus;
  bool _hasInternet = true;

  @override
  Widget build(BuildContext context) {
    final connectivityStatus =
        Provider.of<ConnectivityProvider>(context).connectionStatus;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isConnected = await _checkInternetAccess();

      if (_previousStatus == ConnectivityResult.none && isConnected) {
        // Only show connected message after losing connection
        if (connectivityStatus == ConnectivityResult.mobile) {
          ShowSnackbar().showSnackbar("Connected to Mobile Data", Colors.green, context);
        } else if (connectivityStatus == ConnectivityResult.wifi) {
          ShowSnackbar().showSnackbar("Connected to WiFi", Colors.green, context);
        }
      } else if (!isConnected) {
        // Show "No Internet Connection" when there's no actual internet
        ShowSnackbar().showSnackbar("No Internet Connection", Colors.red, context);
      }

      _previousStatus = connectivityStatus;
      _hasInternet = isConnected;
    });

    return widget.child;
  }

  /// ✅ Check if actual internet is available by pinging Google
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false; // No internet access
    }
  }
}
