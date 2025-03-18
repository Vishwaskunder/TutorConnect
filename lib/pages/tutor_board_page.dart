import 'package:flutter/material.dart';
import 'package:tutorconnect_app/pages/tutor_availability_management_page.dart'; // Make sure this is the right page.
import 'package:tutorconnect_app/pages/booking_request_page.dart';
class TutorBoard extends StatelessWidget {
  final String username;
  const TutorBoard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text("tutor@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.blueAccent),
              title: Text('My Sessions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TutorAvailability()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_page, color: Colors.blueAccent),
              title: Text('Booking Requests'),
              onTap: () {
                // Navigate to Booking Requests page
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => BookingRequestsPage()), // Replace with your actual page
                // );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Colors.blueAccent),
              title: Text('Payments'),
              onTap: () {
                // Navigate to Payments page
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => PaymentsPage()), // Replace with your actual page
                // );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                // Implement logout logic
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Manage your sessions, requests, and earnings with ease.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _dashboardCard(Icons.schedule, 'My Sessions', Colors.blueAccent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TutorAvailability()),
                    );
                  }),
                  _dashboardCard(Icons.request_page, 'Booking Requests', Colors.orangeAccent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingRequestsPage()), // Replace with your page
                    );
                  }),
                  _dashboardCard(Icons.payment, 'Payments', Colors.green, () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => PaymentsPage()), // Replace with your page
                    // );
                  }),
                  _dashboardCard(Icons.settings, 'Settings', Colors.purpleAccent, () {
                    // // Navigate to Settings page
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SettingsPage()), // Replace with your page
                    // );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: GestureDetector(
        onTap: onTap,  // Calls onTap when tapped
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
