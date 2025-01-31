import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  final List<Map<String, String>> contacts = [
    {"title": "Vasu ch", "number": "9959552795"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'Emergency Contacts',
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please don't hesitate to reach us out if you have any queries",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 0),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      contacts[index]["title"]!,
                      style: TextStyle(
                        color: Color.fromARGB(255, 30, 123, 179),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      contacts[index]["number"]!,
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call, color: Colors.black),
                      onPressed: () {
                        final phoneNumber = contacts[index]["number"]!;
                        launch('tel:$phoneNumber');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
