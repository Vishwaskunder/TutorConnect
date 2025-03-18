import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorconnect_app/pages/settings_page.dart';
import 'package:tutorconnect_app/pages/aboutus_page.dart';
import 'package:tutorconnect_app/pages/notifications_page.dart'; // Page for notifications
import 'package:tutorconnect_app/pages/profile_page.dart'; // Page for profile
import 'package:tutorconnect_app/pages/home_content_page.dart';
import 'package:tutorconnect_app/pages/Chatpage.dart';
import 'package:tutorconnect_app/pages/login_tuor_admin.dart';
import 'package:tutorconnect_app/pages/dashboard_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
  const HomeContentPage(), // Use the new HomeContentPage here
  ChatPage(), // Tutors Page Content
  DashboardPage(),
  NotificationsPage(), // Notifications Page Content
 
  ProfilePage(), // Profile Page Content
];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void signUserOut() {
    _auth.signOut().then((_) {
      Navigator.of(context).pushReplacementNamed('/login'); // Navigate to Auth page
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo1.webp',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text('TutorConnect'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _auth.currentUser?.email ?? 'User Email',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Welcome!',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('HOME'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('SETTINGS'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),

           
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login as Tutor/Admin'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginTutorAdminPage()),
              );
            },
            ),


            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LOGOUT'),
              onTap: signUserOut,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.message), // Changed icon to message
            label: 'Chat', // Updated label
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), // Changed icon to message
            label: 'Dashboard', // Updated label
          ),
     
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.blue,
        backgroundColor: Colors.grey[700],
        onTap: _onItemTapped,
      ),
    );
  }
}

