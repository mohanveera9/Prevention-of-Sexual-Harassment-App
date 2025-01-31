import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posh/Model/ComplaintModel.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    // Parse and format the date
    final DateTime parsedDate = DateTime.parse(complaint.time);
    final String formattedDate =
        DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);

    // Function to show popup
    void _showNotificationPopup(BuildContext context, ComplaintModel complaint) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Complaint Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statement
                  Text(
                    'Statement:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    complaint.statement,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  // Description
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    complaint.description,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              // Delete button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Implement delete logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Complaint deleted'),
                    ),
                  );
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        _showNotificationPopup(context, complaint);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.statement,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              complaint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle,
                    size: 12, color: _getStatusColor(complaint.status)),
                SizedBox(width: 8),
                Text(
                  complaint.status,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to determine status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'solved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
