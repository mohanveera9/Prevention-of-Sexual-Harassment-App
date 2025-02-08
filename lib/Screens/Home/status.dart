import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:posh/Model/ComplaintModel.dart';
import 'package:posh/Model/DataProvider.dart';
import 'package:posh/Model/connectivity_wrapper.dart';
import 'package:posh/Widgets/ComplaintCard.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  bool _isLoading = true; // To control shimmer effect

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is first opened
    _fetchData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    const apiUrl =
        'https://tech-hackathon-glowhive.onrender.com/api/complaints/user';
    final token = await getToken(); // Replace with your token logic

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Parse the response as a Map
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract the complaints list
        final List<dynamic> complaintsData = responseData['complaints'];

        // Map the list to ComplaintModel
        final List<ComplaintModel> complaints = complaintsData
            .map((json) => ComplaintModel.fromJson(json))
            .toList();

        // Update the complaints in the DataProvider
        dataProvider.updateComplaints(complaints);
      } else {
        throw Exception(
            'Failed to fetch complaints. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching complaints: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop shimmer effect
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Complaint Status',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchData(),
                child: _isLoading
                    ? _buildShimmerEffect() // Show shimmer effect while loading
                    : dataProvider.complaints.isEmpty
                        ? Center(child: Text('No complaints available'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: dataProvider.complaints.length,
                            itemBuilder: (context, index) {
                              final complaint = dataProvider.complaints[index];
                              if (complaint.statement.isEmpty ||
                                  complaint.description.isEmpty) {
                                return SizedBox.shrink();
                              }
                              return ComplaintCard(
                                complaint: complaint,
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer effect widget
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            height: 100, // Height of the shimmer placeholder
          ),
        );
      },
    );
  }
}
