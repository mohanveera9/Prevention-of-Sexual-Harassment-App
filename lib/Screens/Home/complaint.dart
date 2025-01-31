import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:posh/Widgets/customButton.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Complaint extends StatefulWidget {
  final String id;
  const Complaint({super.key, required this.id});

  @override
  _ComplaintState createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  String? selectedComplaintType;
  String? selectedComplaintCategory;
  String? selectedAdditionalType;
  bool isAnonymous = false;
  bool isCriticality = false;
  TextEditingController otherCategoryController = TextEditingController();
  TextEditingController statementController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController victimDetailsController = TextEditingController();
  TextEditingController harasserDetailsController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  bool isLoading = false;

  final Map<String, List<String>> complaintCategories = {
    'Harassment': [
      'Verbal Abuse',
      'Sexual Harassment',
      'Bullying',
      'Stalking',
      'Cyber Harassment',
      'Discrimination',
      'Abuse of Authority by Staff or Faculty',
      'Others'
    ],
    'Personal': ['Hostel', 'Academics', 'FC', 'Others'],
    'General': ['Hostel', 'Academics', 'FC', 'Others'],
  };

  final Map<String, List<String>> additionalDropdownItems = {
    'Verbal Abuse': [
      'Intimidation,',
      'Demeaning language,',
      'Public humiliation',
      'Other'
    ],
    'Sexual Harassment': [
      'Unwanted Touching',
      'Explicit Comments',
      'Coercive requests for favors',
      'Other'
    ],
    'Bullying': [
      'Spreading rumors,',
      'Public embarrassment,',
      'Abuse of power',
      'Other'
    ],
    'Stalking': [
      'Monitoring movements',
      'Recording without consent',
      'Leaving unsolicited gifts',
      'Others'
    ],
    'Cyber Harassment': [
      'Excessive messaging',
      'Hacking accounts',
      'Sharing inappropriate content',
      'Others'
    ],
    'Discrimination': [
      'Unequal academic opportunities',
      'Exclusion',
      'Religious barriers',
      'Others'
    ],
    'Abuse of Authority by Staff or Faculty': [
      'Unwelcome physical contact',
      'Favoritism',
      'Threats',
      'Others'
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Type Dropdown
                  Text(
                    "Complaint Type:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildDropdownButton(
                    "Select Type",
                    ["Harassment", "Personal", "General"],
                    selectedComplaintType,
                    (value) {
                      setState(() {
                        selectedComplaintType = value;
                        selectedComplaintCategory = null; // Reset category
                        selectedAdditionalType =
                            null; // Reset additional dropdown
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  // Complaint Category Dropdown
                  Text(
                    "Complaint Category:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildDropdownButton(
                    "Select Category",
                    selectedComplaintType == null
                        ? []
                        : complaintCategories[selectedComplaintType]!,
                    selectedComplaintCategory,
                    (value) {
                      setState(() {
                        selectedComplaintCategory = value;
                        selectedAdditionalType =
                            null; // Reset additional dropdown when category changes
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  if (selectedComplaintCategory == 'Others') ...[
                    _buildTextField("Specify Category",
                        controller: otherCategoryController),
                    SizedBox(height: 20),
                  ],
                  if (selectedComplaintType == 'Harassment' &&
                      selectedComplaintCategory != null) ...[
                    Text(
                      "${selectedComplaintCategory} Type:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDropdownButton(
                      "${selectedComplaintCategory} Type",
                      additionalDropdownItems[selectedComplaintCategory] ?? [],
                      selectedAdditionalType,
                      (value) {
                        setState(() {
                          selectedAdditionalType = value;
                        });
                      },
                    ),
                    if (selectedAdditionalType == 'Others') ...[
                      _buildTextField(
                        "Specify ${selectedComplaintCategory} Type",
                        controller: otherCategoryController,
                      ),
                      SizedBox(height: 20),
                    ],
                    SizedBox(height: 20),
                  ],
                  // Statement TextField
                  Text(
                    "Statement:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField("Add Statement here...",
                      controller: statementController),
                  SizedBox(height: 20),
                  // Additional fields for Harassment
                  if (selectedComplaintType == 'Harassment') ...[
                    _buildTextField("Time of Incident",
                        controller: timeController),
                    SizedBox(height: 10),
                    _buildTextField("Location of Incident",
                        controller: locationController),
                    SizedBox(height: 10),
                    _buildTextField("Harasser Details",
                        controller: harasserDetailsController),
                    SizedBox(height: 20),
                  ] else if (selectedComplaintType == 'Personal' ||
                      selectedComplaintType == 'General') ...[
                    _buildTextField("Victim Details",
                        controller: victimDetailsController),
                    SizedBox(height: 20),
                  ],
                  // Description TextField
                  Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField("Write a few lines...",
                      controller: descriptionController, maxLines: 5),
                  SizedBox(height: 20),
                  Text(
                    "Criticality",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text("Yes"),
                          value: true,
                          groupValue: isCriticality,
                          onChanged: (value) {
                            setState(() {
                              isCriticality = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text("No"),
                          value: false,
                          groupValue: isCriticality,
                          onChanged: (value) {
                            setState(() {
                              isCriticality = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),
                  // Send Mail Button
                  customButton(
                    isLoading: isLoading,
                    function: () {
                      _validateAndSendComplaint();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,
                    text: 'Send Complaint',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateAndSendComplaint() async {
    // Check if all required fields are filled
    if (selectedComplaintType == null) {
      _showSnackbar('Please select a complaint type.');
      return;
    }
    if (selectedComplaintCategory == null) {
      _showSnackbar('Please select a complaint category.');
      return;
    }
    if (selectedComplaintCategory == 'Others' &&
        otherCategoryController.text.trim().isEmpty) {
      _showSnackbar('Please specify the complaint category.');
      return;
    }
    if (statementController.text.trim().isEmpty) {
      _showSnackbar('Please provide a statement.');
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showSnackbar('Please provide a description.');
      return;
    }
    if (selectedComplaintType == 'Harassment') {
      if (timeController.text.trim().isEmpty) {
        _showSnackbar('Please specify the time of the incident.');
        return;
      }
      if (locationController.text.trim().isEmpty) {
        _showSnackbar('Please specify the location of the incident.');
        return;
      }
      if (harasserDetailsController.text.trim().isEmpty) {
        _showSnackbar('Please provide harasser details.');
        return;
      }
    }

    // If all validations pass, send the complaint
    await _sendComplaint();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _sendComplaint() async {
    String userId = isAnonymous
        ? ""
        : widget.id; // Assuming "user123" is the logged-in user's ID

    // Prepare the complaint data
    Map<String, dynamic> complaintData = {
      'statement': statementController.text,
      'description': descriptionController.text,
      'category': selectedComplaintCategory ?? "",
      'userId': userId,
      'location': locationController.text,
      'time': timeController.text,
      'victimDetails': victimDetailsController.text,
      'harasserDetails': harasserDetailsController.text,
      'harasserType': selectedAdditionalType ?? "",
      'isCritical': isCriticality,
    };

    Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    }

    try {
      setState(() {
        isLoading = true;
      });
      final token = await getToken();
      var response = await http.post(
        Uri.parse(
            'https://tech-hackathon-glowhive.onrender.com/api/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Correctly pass the token
        },
        body: json.encode(complaintData),
      );

      if (response.statusCode == 200) {
        // Success: Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint sent successfully!')),
        );

        // Clear all text fields after success
        statementController.clear();
        descriptionController.clear();
        otherCategoryController.clear();
        victimDetailsController.clear();
        harasserDetailsController.clear();
        locationController.clear();
        timeController.clear();
        setState(() {
          selectedComplaintType = null;
          selectedComplaintCategory = null;
          selectedAdditionalType = null;
          isAnonymous = false;
        });
      } else {
        // Error: Show error Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send complaint. Please try again!')),
        );
      }
    } catch (e) {
      // Error: Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "An error occurred. Please check your internet connection.")),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  // Dropdown builder
  Widget _buildDropdownButton(String hint, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedValue,
        underline: SizedBox(),
        hint: Text(hint),
        items: items.isEmpty
            ? []
            : items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Text field builder
  Widget _buildTextField(String hint,
      {int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
