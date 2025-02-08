import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:posh/Model/ComplaintModel.dart';

class DataProvider extends ChangeNotifier {
  String? _token;
  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;

  String? get token => _token;
  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void updateComplaints(List<ComplaintModel> newComplaints) {
    _complaints = newComplaints;
    notifyListeners();
  }

  Future<void> fetchData() async {
    if (_token == null) {
      debugPrint('Error: Token is null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://tech-hackathon-glowhive.onrender.com/api/complaints/user'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('Complaints Response Status: ${response.statusCode}');
      print('Complaints Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> complaintsData = data['complaints'] ?? [];
        
        _complaints = complaintsData.map((json) => ComplaintModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch complaints: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
