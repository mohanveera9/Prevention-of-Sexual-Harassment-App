import 'package:flutter/material.dart';

class Soshelp extends StatelessWidget {
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
              'Help',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Welcome to '),
                    TextSpan(
                      text: 'Girls Grievance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ', your comprehensive solution for addressing grievances and ensuring safety. '
                          'This app has been designed with simplicity and effectiveness in mind, enabling users to navigate seamlessly and take action whenever needed.',
                    ),
                  ],
                ),
              ),
            ),
            // Features Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS Feature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'In case of an emergency, the SOS feature allows users to tap a button that triggers a fake call. During this call, the app records audio or video of the situation, capturing important details. These recordings are then automatically sent to the pre-listed emergency contacts or the designated authorities for swift response and action. This ensures that the incident is documented with both SOS video capturing and SOS audio capturing, which can serve as valuable evidence for any case.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mobile Gesturing for Emergency Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'The mobile gesturing process is designed to provide an additional layer of safety in case you cannot access the app due to network issues, app unresponsiveness, or other emergencies. This feature allows users to trigger an emergency action without directly interacting with the phone\'s screen.\n\n'
                    'For example, predefined gestures like pressing the power button multiple times (typically 3 to 5 times) can activate an emergency call or the SOS feature. This gesture is recognized by the app and immediately triggers the following actions:\n\n'
                    '• Initiates SOS Action: The app automatically starts recording audio or video of the situation, just like the SOS button within the app.\n'
                    '• Emergency Call Activation: If the app is unable to send the SOS alert directly due to network issues, the gesture can initiate an emergency call to pre-listed contacts or emergency services.\n'
                    '• Notifies Authorities: Once the gesture activates the SOS feature, the app will send the audio/video recording to the designated authorities or emergency contacts in your list.\n\n'
                    'The advantage of this feature is that it works even if the app is not open, or if you’re unable to navigate through the app, providing a quick and efficient way to ensure your safety during critical situations.\n\n'
                    'Additionally, if you encounter network connectivity issues or cannot open the app, predefined mobile gestures (e.g., pressing the power button multiple times) can automatically trigger an emergency call, ensuring that emergency services or contacts are notified and assistance is on its way, even without internet access or opening the app.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper method to build feature items
  Widget buildFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
