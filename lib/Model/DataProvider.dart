import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:posh/Model/ComplaintModel.dart';
import 'package:posh/Model/NotificationModel.dart';

class DataProvider extends ChangeNotifier {
  String? _token;

  String? get token => _token;

  // Set token directly
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  List<NotificationModel> _notifications = [];
  List<ComplaintModel> _complaints = [];

  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;

  // Method to update complaints
  void updateComplaints(List<ComplaintModel> newComplaints) {
    _complaints = newComplaints;
    notifyListeners(); // Notify listeners about the change
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Notifications
      final notificationResponse = await http.get(
        Uri.parse(
            'https://tech-hackathon-glowhive.onrender.com/api/notifications'),
        headers: {
          'Authorization':
              'Bearer $token', // Add the token directly in the header
        },
      );

      if (notificationResponse.statusCode == 200) {
        List<dynamic> notificationData =
            json.decode(notificationResponse.body)['notifications'];
        _notifications = notificationData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifyListeners(); // Update listeners when notifications data is updated
      } else {
        print(
            'Failed to load notifications: ${notificationResponse.statusCode}');
      }


      // Fetch Complaints
      final complaintsResponse = await http.get(
        Uri.parse(
            'https://tech-hackathon-glowhive.onrender.com/api/complaints/user'),
        headers: {
          'Authorization':
              'Bearer $token', // Add the token directly in the header
        },
      );
      print('Complaints Response Status: ${complaintsResponse.statusCode}');
      print('Complaints Response Body: ${complaintsResponse.body}');

      if (complaintsResponse.statusCode == 200) {
        List<dynamic> complaintsData =
            json.decode(complaintsResponse.body)['complaints'];
        _complaints = complaintsData
            .map((json) => ComplaintModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching data1: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners after the data fetch is complete
    }
  }
}
