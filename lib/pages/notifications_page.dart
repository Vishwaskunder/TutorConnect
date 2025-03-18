import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Method to fetch notifications from Firestore
  Future<List<String>> _fetchNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return []; // Return empty list if the user is not logged in
    }

    try {
      // Fetch notifications for the logged-in user's email
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('Notifications')
          .where('email', isEqualTo: currentUser.email) // Match user email
          .get();

      // Extract the message content from the documents
      return notificationsSnapshot.docs.map((doc) {
        final data = doc.data(); // No need for explicit cast
        return data['message'] as String? ?? 'No message'; // Ensure type-safety
      }).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // appBar: AppBar(
      //   title: const Text("Notifications"),
      // ),
      body: FutureBuilder<List<String>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching notifications: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications available.'),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final message = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(message),
                  onTap: () {
                    // Handle notification tap if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});

//   Future<List<Map<String, dynamic>>> _fetchNotifications(String currentUserEmail) async {
//     final notifications = <Map<String, dynamic>>[];

//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('Notifications')
//           .where('email', isEqualTo: currentUserEmail) // Fetch notifications for the current user
//           .orderBy('timestamp', descending: true) // Order by timestamp (newest first)
//           .get();

//       for (var doc in snapshot.docs) {
//         notifications.add(doc.data());
//       }
//     } catch (e) {
//       print("Error fetching notifications: $e"); // Debugging error
//     }

//     return notifications;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       // If no user is logged in, display a message
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Notifications"),
//         ),
//         body: const Center(
//           child: Text('You must be logged in to view notifications.'),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         title: const Text("Notifications"),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>( 
//         future: _fetchNotifications(currentUser.email!), // Pass the current user's email
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error fetching notifications: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No notifications available.'));
//           }

//           final notifications = snapshot.data!;

//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications[index];

//               // Accessing the message field from the notification
//               final message = notification['message'] ?? 'No message available';

//               return ListTile(
//                 leading: const Icon(Icons.notifications, color: Colors.blue),
//                 title: Text("Notification #${index + 1}"),
//                 subtitle: Text(message), // Display the notification message here
//                 trailing: const Icon(Icons.arrow_forward_ios),
//                 onTap: () {
//                   // Handle notification tap
//                   // You can navigate to a specific page or show more details here
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';

// // class NotificationsPage extends StatelessWidget {
// //   const NotificationsPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Theme.of(context).colorScheme.background,
// //       appBar: AppBar(
// //         title: const Text("Notifications"),
// //       ),
// //       body: ListView.builder(
// //         itemCount: 10, // Replace with the actual number of notifications
// //         itemBuilder: (context, index) {
// //           return ListTile(
// //             leading: Icon(Icons.notifications, color: Colors.blue),
// //             title: Text("Notification #${index + 1}"),
// //             subtitle: Text("This is a notification message."),
// //             trailing: Icon(Icons.arrow_forward_ios),
// //             onTap: () {
// //               // Handle notification tap
// //               // You can navigate to a specific page or show more details
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
