import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

class BookingRequestsPage extends StatefulWidget {
  @override
  _BookingRequestsPageState createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

  String? currentTutorEmail;

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String tutorEmail = currentUser.email!;
      currentTutorEmail = tutorEmail;

      final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

      if (doc.exists && doc.data()?['availability'] != null) {
        Map<String, dynamic> fetchedData = doc.data()!['availability'];
        Map<String, Map<String, String>> formattedData = {};

        fetchedData.forEach((date, slots) {
          Map<String, String> parsedSlots = {};
          (slots as Map<String, dynamic>).forEach((timeSlot, status) {
            parsedSlots[timeSlot] = status;
          });
          formattedData[date] = parsedSlots;
        });

        setState(() {
          tutorAvailability[tutorEmail] = formattedData;
        });
      }
    } else {
      print("No user is logged in.");
    }
  }

  Future<void> _updateBookingStatus({
    required String tutorEmail,
    required String timeslot, 
    required String newStatus, 
  }) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Booking_info')
        .where('Tutor_Email', isEqualTo: tutorEmail)
        .where('timeslot', isEqualTo: timeslot)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'status': newStatus});

      String studentEmail = doc.get('Student_Email');

      if (newStatus == 'Cancelled') {
        await _firestore.collection('Notifications').add({
          'email': tutorEmail,
          'message': "You have rejected the session with $studentEmail on $timeslot.",
          'timestamp': DateTime.now().toIso8601String(),
        });

        await _firestore.collection('Notifications').add({
          'email': studentEmail,
          'message': "Sorry, $tutorEmail has rejected your request. Your amount will be returned back soon.",
          'timestamp': DateTime.now().toIso8601String(),
        });

      } else if (newStatus == 'Confirmed') {
        await _firestore.collection('Notifications').add({
          'email': tutorEmail,
          'message': "You have confirmed the session with $studentEmail on $timeslot.",
          'timestamp': DateTime.now().toIso8601String(),
        });

        await _firestore.collection('Notifications').add({
          'email': studentEmail,
          'message': "Your session with $tutorEmail is confirmed for $timeslot.",
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }

    if (newStatus == 'Confirmed') {
      List<String> parts = timeslot.split(' ');
      if (parts.isNotEmpty) {
        String date = parts[0];
        String slot = timeslot.substring(date.length).trim();
        await _firestore.collection('Tutor_Sessions').doc(tutorEmail).update({
          'availability.$date.$slot': 'Booked'
        });
      }
    }

    if (newStatus == 'Cancelled') {
      List<String> parts = timeslot.split(' ');
      if (parts.isNotEmpty) {
        String date = parts[0];
        String slot = timeslot.substring(date.length).trim();
        await _firestore.collection('Tutor_Sessions').doc(tutorEmail).update({
          'availability.$date.$slot': 'Cancelled'
        });
      }
    }


    await _fetchAvailability();
  }

  void _showPendingDialog({
    required String date,
    required String slot,
  }) {
    String timeslot = "$date $slot";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pending Request"),
          content: Text("Please accept the class soon. The student is waiting for your confirmation."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel: simply close the dialog.
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (currentTutorEmail != null) {
                  await _updateBookingStatus(
                    tutorEmail: currentTutorEmail!,
                    timeslot: timeslot,
                    newStatus: 'Cancelled',
                  );
                  // Refresh the UI after rejection
                  setState(() {
                    tutorAvailability[currentTutorEmail]?[date]?[slot] = 'Cancelled';
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Reject"),
            ),
            TextButton(
              onPressed: () async {
                if (currentTutorEmail != null) {
                  await _updateBookingStatus(
                    tutorEmail: currentTutorEmail!,
                    timeslot: timeslot,
                    newStatus: 'Confirmed',
                  );
                  // Refresh the UI after confirmation
                  setState(() {
                    tutorAvailability[currentTutorEmail]?[date]?[slot] = 'Booked';
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  String _getDayOfWeek(String dateString) {
    try {
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
      return DateFormat('EEEE').format(date);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentTutorEmail == null || tutorAvailability[currentTutorEmail!] == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Booking Requests'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Map<String, Map<String, String>> currentAvailability = tutorAvailability[currentTutorEmail!]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Requests'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Please confirm the class by accepting pending requests; otherwise, you may incur a fine.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[900],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: currentAvailability.keys.length,
                itemBuilder: (context, index) {
                  String date = currentAvailability.keys.elementAt(index);
                  Map<String, String> slots = currentAvailability[date]!;

                  var filteredSlots = slots.entries.where((entry) {
                    return entry.value == 'Requested' || entry.value == 'Booked' || entry.value == 'Cancelled';
                  }).toList();

                  if (filteredSlots.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getDayOfWeek(date),
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      children: filteredSlots.map((entry) {
                        if (entry.value == 'Booked') {
                          return ListTile(
                            leading: Icon(Icons.access_time, color: Colors.blue),
                            title: Text(entry.key, style: TextStyle(fontSize: 16)),
                            trailing: Chip(
                              label: Text(
                                'Confirmed',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (entry.value == 'Requested') {
                          return ListTile(
                            leading: Icon(Icons.access_time, color: Colors.orange),
                            title: Text(entry.key, style: TextStyle(fontSize: 16)),
                            trailing: TextButton(
                              onPressed: () {
                                _showPendingDialog(date: date, slot: entry.key);
                              },
                              child: Text('Pending'),
                            ),
                          );
                        } else {
                          return ListTile(
                            leading: Icon(Icons.access_time, color: Colors.red),
                            title: Text(entry.key, style: TextStyle(fontSize: 16)),
                            trailing: Chip(
                              label: Text(
                                'Cancelled',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; 

// class BookingRequestsPage extends StatefulWidget {
//   @override
//   _BookingRequestsPageState createState() => _BookingRequestsPageState();
// }

// class _BookingRequestsPageState extends State<BookingRequestsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

//   String? currentTutorEmail;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAvailability();
//   }

//   Future<void> _fetchAvailability() async {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       String tutorEmail = currentUser.email!;
//       currentTutorEmail = tutorEmail;

//       final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

//       if (doc.exists && doc.data()?['availability'] != null) {
//         Map<String, dynamic> fetchedData = doc.data()!['availability'];
//         Map<String, Map<String, String>> formattedData = {};

//         fetchedData.forEach((date, slots) {
//           Map<String, String> parsedSlots = {};
//           (slots as Map<String, dynamic>).forEach((timeSlot, status) {
//             parsedSlots[timeSlot] = status;
//           });
//           formattedData[date] = parsedSlots;
//         });

//         setState(() {
//           tutorAvailability[tutorEmail] = formattedData;
//         });
//       }
//     } else {
//       print("No user is logged in.");
//     }
//   }

//   Future<void> _updateBookingStatus({
//     required String tutorEmail,
//     required String timeslot, 
//     required String newStatus, 
//   }) async {
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('Booking_info')
//         .where('Tutor_Email', isEqualTo: tutorEmail)
//         .where('timeslot', isEqualTo: timeslot)
//         .get();

//     for (var doc in querySnapshot.docs) {
//       await doc.reference.update({'status': newStatus});

//       String studentEmail = doc.get('Student_Email');

//       if (newStatus == 'Cancelled') {
//         await _firestore.collection('Notifications').add({
//           'email': tutorEmail,
//           'message': "You have rejected the session with $studentEmail on $timeslot.",
//           'timestamp': DateTime.now().toIso8601String(),
//         });

//         await _firestore.collection('Notifications').add({
//           'email': studentEmail,
//           'message': "Sorry, $tutorEmail has rejected your request. Your amount will be returned back soon.",
//           'timestamp': DateTime.now().toIso8601String(),
//         });

//       } else if (newStatus == 'Confirmed') {
//         await _firestore.collection('Notifications').add({
//           'email': tutorEmail,
//           'message': "You have confirmed the session with $studentEmail on $timeslot.",
//           'timestamp': DateTime.now().toIso8601String(),
//         });

//         await _firestore.collection('Notifications').add({
//           'email': studentEmail,
//           'message': "Your session with $tutorEmail is confirmed for $timeslot.",
//           'timestamp': DateTime.now().toIso8601String(),
//         });
//       }
//     }

//     if (newStatus == 'Confirmed') {
//       List<String> parts = timeslot.split(' ');
//       if (parts.isNotEmpty) {
//         String date = parts[0];
//         String slot = timeslot.substring(date.length).trim();
//         await _firestore.collection('Tutor_Sessions').doc(tutorEmail).update({
//           'availability.$date.$slot': 'Booked'
//         });
//       }
//     }

//     await _fetchAvailability();
//   }

//   void _showPendingDialog({
//     required String date,
//     required String slot,
//   }) {
//     String timeslot = "$date $slot";
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Pending Request"),
//           content: Text("Please accept the class soon. The student is waiting for your confirmation."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Cancel: simply close the dialog.
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 if (currentTutorEmail != null) {
//                   await _updateBookingStatus(
//                     tutorEmail: currentTutorEmail!,
//                     timeslot: timeslot,
//                     newStatus: 'Cancelled',
//                   );
//                 }
//                 Navigator.pop(context);
//               },
//               child: Text("Reject"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 if (currentTutorEmail != null) {
//                   await _updateBookingStatus(
//                     tutorEmail: currentTutorEmail!,
//                     timeslot: timeslot,
//                     newStatus: 'Confirmed',
//                   );
//                 }
//                 Navigator.pop(context);
//               },
//               child: Text("Accept"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String _getDayOfWeek(String dateString) {
//     try {
//       DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
//       return DateFormat('EEEE').format(date);
//     } catch (e) {
//       return "";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentTutorEmail == null || tutorAvailability[currentTutorEmail!] == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Booking Requests'),
//           centerTitle: true,
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     Map<String, Map<String, String>> currentAvailability = tutorAvailability[currentTutorEmail!]!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Booking Requests'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.lightBlueAccent.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 'Please confirm the class by accepting pending requests; otherwise, you may incur a fine.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.blue[900],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: currentAvailability.keys.length,
//                 itemBuilder: (context, index) {
//                   String date = currentAvailability.keys.elementAt(index);
//                   Map<String, String> slots = currentAvailability[date]!;

//                   var filteredSlots = slots.entries.where((entry) {
//                     return entry.value == 'Requested' || entry.value == 'Booked' || entry.value == 'Cancelled';
//                   }).toList();

//                   if (filteredSlots.isEmpty) {
//                     return SizedBox.shrink();
//                   }

//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     elevation: 4,
//                     child: ExpansionTile(
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             date,
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             _getDayOfWeek(date),
//                             style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                           ),
//                         ],
//                       ),
//                       children: filteredSlots.map((entry) {
//                         if (entry.value == 'Booked') {
//                           return ListTile(
//                             leading: Icon(Icons.access_time, color: Colors.blue),
//                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
//                             trailing: Chip(
//                               label: Text(
//                                 'Confirmed',
//                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                               ),
//                               backgroundColor: Colors.green,
//                             ),
//                           );
//                         } else if (entry.value == 'Requested') {
//                           return ListTile(
//                             leading: Icon(Icons.access_time, color: Colors.orange),
//                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
//                             trailing: TextButton(
//                               onPressed: () {
//                                 _showPendingDialog(date: date, slot: entry.key);
//                               },
//                               child: Text('Pending'),
//                             ),
//                           );
//                         } else {
//                           return ListTile(
//                             leading: Icon(Icons.access_time, color: Colors.red),
//                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
//                             trailing: Chip(
//                               label: Text(
//                                 'Cancelled',
//                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                               ),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       }).toList(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; 

// class BookingRequestsPage extends StatefulWidget {
//   @override
//   _BookingRequestsPageState createState() => _BookingRequestsPageState();
// }

// class _BookingRequestsPageState extends State<BookingRequestsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   /// Each tutor email maps to a Map of date → (time slot → status)
//   Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

//   String? currentTutorEmail;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAvailability();
//   }

//   /// Fetch availability for the current tutor.
//   Future<void> _fetchAvailability() async {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       String tutorEmail = currentUser.email!;
//       currentTutorEmail = tutorEmail;

//       final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

//       if (doc.exists && doc.data()?['availability'] != null) {
//         Map<String, dynamic> fetchedData = doc.data()!['availability'];
//         Map<String, Map<String, String>> formattedData = {};

//         // For each date, convert the slots to a Map<String, String>
//         fetchedData.forEach((date, slots) {
//           Map<String, String> parsedSlots = {};
//           (slots as Map<String, dynamic>).forEach((timeSlot, status) {
//             parsedSlots[timeSlot] = status;
//           });
//           formattedData[date] = parsedSlots;
//         });

//         setState(() {
//           // Save the availability data under the tutor's email
//           tutorAvailability[tutorEmail] = formattedData;
//         });
//       }
//     } else {
//       print("No user is logged in.");
//     }
//   }

//   /// Update the booking status in Booking_info and add a notification.
//   ///
//   /// This function:
//   /// 1. Queries Booking_info for documents with the given Tutor_Email, timeslot, and status "Panding".
//   /// 2. For each matching document, updates its status to newStatus.
//   /// 3. Retrieves the Student_Email from the document.
//   /// 4. Adds a notification document that includes both Tutor_Email and Student_Email.
//   /// 5. If newStatus is "Confirmed", updates the Tutor_Sessions availability (changing "Requested" to "Booked").
//   Future<void> _updateBookingStatus({
//     required String tutorEmail,
//     required String timeslot, // Expected format: "date slot" (e.g., "2025-02-05 10:00 AM - 11:00 AM")
//     required String newStatus, // "Cancelled" or "Confirmed"
//   }) async {
//     // Query Booking_info documents matching tutorEmail, timeslot, and status "Panding"
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('Booking_info')
//         .where('Tutor_Email', isEqualTo: tutorEmail)
//         .where('timeslot', isEqualTo: timeslot)
//         // .where('status', isEqualTo: 'Panding')
//         .get();

//     for (var doc in querySnapshot.docs) {
//       // Update booking status in the booking document.
//       await doc.reference.update({'status': newStatus});

//       // Retrieve the student email from the booking document.
//       String studentEmail = doc.get('Student_Email');

//       // Add a notification document with both Tutor_Email and Student_Email.
      
//        // Depending on the newStatus, add a notification with a different notification_type.
//       if (newStatus == 'Cancelled') {
//         await _firestore.collection('Notifications').add({
//           'email': tutorEmail,
//           'message': "You have rejected  session with $studentEmail on $timeslot don't reject.You may gat fine",
//           'timestamp': DateTime.now().toIso8601String(),
//         });

//         await _firestore.collection('Notifications').add({
//           'email': studentEmail,
//           'message':"Sorry $tutorEmail has rejected  your request  your amount will return back soon..",
//           'timestamp': DateTime.now().toIso8601String(),
//         });

//       } else if (newStatus == 'Confirmed') {

//         await _firestore.collection('Notifications').add({
//           'email': tutorEmail,
//           'message': "Thank you,You have Confirmed session with $studentEmail on $timeslot",
//           'timestamp': DateTime.now().toIso8601String(),
//         });

//         await _firestore.collection('Notifications').add({
//           'email': studentEmail,
//           'message': "You request is acepted by $tutorEmail, you will get appointement on $timeslot",
//           'timestamp': DateTime.now().toIso8601String(),
//         });


//       }
//     }

//     // If accepting the booking, update Tutor_Sessions availability (set slot to "Booked").
//     if (newStatus == 'Confirmed') {
//       // Expect timeslot to be "date slot", where the first part is the date.
//       List<String> parts = timeslot.split(' ');
//       if (parts.isNotEmpty) {
//         String date = parts[0];
//         // The remainder of the timeslot string is the slot.
//         String slot = timeslot.substring(date.length).trim();
//         await _firestore.collection('Tutor_Sessions').doc(tutorEmail).update({
//           'availability.$date.$slot': 'Booked'
//         });
//       }
//     }

//     // Refresh the tutor availability data.
//     await _fetchAvailability();
//   }

//   /// Display a pop-up dialog when the tutor taps the pending button.
//   void _showPendingDialog({
//     required String date,
//     required String slot,
//   }) {
//     String timeslot = "$date $slot";
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Pending Request"),
//           content: Text("Plz accept the class soon. Student is waiting for your confirmation."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Cancel: simply close the dialog.
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Reject: update status to "Cancelled"
//                 if (currentTutorEmail != null) {
//                   await _updateBookingStatus(
//                     tutorEmail: currentTutorEmail!,
//                     timeslot: timeslot,
//                     newStatus: 'Cancelled',
//                   );
//                 }
//                 Navigator.pop(context);
//               },
//               child: Text("Reject"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Accept: update status to "Confirmed"
//                 if (currentTutorEmail != null) {
//                   await _updateBookingStatus(
//                     tutorEmail: currentTutorEmail!,
//                     timeslot: timeslot,
//                     newStatus: 'Confirmed',
//                   );
//                 }
//                 Navigator.pop(context);
//               },
//               child: Text("Accept"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Convert a date string (expected format "yyyy-MM-dd") to its corresponding day of the week.
//   String _getDayOfWeek(String dateString) {
//     try {
//       DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
//       return DateFormat('EEEE').format(date); // e.g., "Monday"
//     } catch (e) {
//       return "";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentTutorEmail == null || tutorAvailability[currentTutorEmail!] == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Booking Requests'),
//           centerTitle: true,
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Get the current tutor's availability.
//     Map<String, Map<String, String>> currentAvailability = tutorAvailability[currentTutorEmail!]!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Booking Requests'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             // Informational message at the top.
//             Container(
//               padding: const EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.lightBlueAccent.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 'Please confirm the class by accepting pending requests; otherwise, you may incur a fine.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.blue[900],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             // Expanded list of dates and time slots.
//             Expanded(
//               child: ListView.builder(
//                 itemCount: currentAvailability.keys.length,
//                 itemBuilder: (context, index) {
//                   String date = currentAvailability.keys.elementAt(index);
//                   Map<String, String> slots = currentAvailability[date]!;

//                   // Filter slots to show only those with status "Requested", "Booked", or "Cancelled"
//                   var filteredSlots = slots.entries.where((entry) {
//                     return entry.value == 'Requested' || entry.value == 'Booked' || entry.value == 'Cancelled';
//                   }).toList();

//                   if (filteredSlots.isEmpty) {
//                     return SizedBox.shrink();
//                   }

//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     elevation: 4,
//                     child: ExpansionTile(
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             date,
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             _getDayOfWeek(date),
//                             style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                           ),
//                         ],
//                       ),
//                       children: filteredSlots.map((entry) {
//                         if (entry.value == 'Booked') {
//                           // For a "Booked" slot, display a chip with "Confirmed".
//                           return ListTile(
//                             leading: Icon(Icons.access_time, color: Colors.blue),
//                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
//                             trailing: Chip(
//                               label: Text(
//                                 'Confirmed',
//                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                               ),
//                               backgroundColor: Colors.green,
//                             ),
//                           );
//                         }
//                         else if (entry.value == 'Cancelled') {
//                           return ListTile(
//                             leading: Icon(Icons.cancel, color: Colors.red),
//                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
//                             trailing: Chip(
//                               label: Text(
//                                 'cancelled',
//                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                               ),
//                               backgroundColor: const Color.fromARGB(255, 233, 70, 70),
//                             ),
//                           );
//                         }
//                          else {
//                           // For a "Requested" slot, show a "Pending" button.
//                           return ListTile(
//                             leading: Icon(Icons.access_time, color: Colors.blue),
//                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
//                             trailing: ElevatedButton(
//                               child: Text("Pending"),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                               ),
//                               onPressed: () {
//                                 _showPendingDialog(
//                                   date: date,
//                                   slot: entry.key,
//                                 );
//                               },
//                             ),
//                           );
//                         }
//                       }).toList(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:intl/intl.dart'; 

// // class BookingRequestsPage extends StatefulWidget {
// //   @override
// //   _BookingRequestsPageState createState() => _BookingRequestsPageState();
// // }

// // class _BookingRequestsPageState extends State<BookingRequestsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   /// Each tutor email maps to a Map of date → (time slot → status)
// //   Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

// //   String? currentTutorEmail;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchAvailability();
// //   }

// //   /// Fetch availability for the current tutor.
// //   Future<void> _fetchAvailability() async {
// //     User? currentUser = _auth.currentUser;
// //     if (currentUser != null) {
// //       String tutorEmail = currentUser.email!;
// //       currentTutorEmail = tutorEmail;

// //       final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

// //       if (doc.exists && doc.data()?['availability'] != null) {
// //         Map<String, dynamic> fetchedData = doc.data()!['availability'];
// //         Map<String, Map<String, String>> formattedData = {};

// //         // For each date, convert the slots to a Map<String, String>
// //         fetchedData.forEach((date, slots) {
// //           Map<String, String> parsedSlots = {};
// //           (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// //             parsedSlots[timeSlot] = status;
// //           });
// //           formattedData[date] = parsedSlots;
// //         });

// //         setState(() {
// //           // Save the availability data under the tutor's email
// //           tutorAvailability[tutorEmail] = formattedData;
// //         });
// //       }
// //     } else {
// //       print("No user is logged in.");
// //     }
// //   }

// //   /// Update the booking status in Booking_info and add a notification.
// //   ///
// //   /// This function:
// //   /// 1. Queries Booking_info for documents with the given Tutor_Email, timeslot, and status "Panding".
// //   /// 2. For each matching document, updates its status to newStatus.
// //   /// 3. Retrieves the Student_Email from the document.
// //   /// 4. Adds a notification document that includes both Tutor_Email and Student_Email.
// //   /// 5. If newStatus is "Confirmed", updates the Tutor_Sessions availability (changing "Requested" to "Booked").
// //   Future<void> _updateBookingStatus({
// //     required String tutorEmail,
// //     required String timeslot, // Expected format: "date slot" (e.g., "2025-02-05 10:00 AM - 11:00 AM")
// //     required String newStatus, // "Cancelled" or "Confirmed"
// //   }) async {
// //     // Query Booking_info documents matching tutorEmail, timeslot, and status "Panding"
// //     QuerySnapshot querySnapshot = await _firestore
// //         .collection('Booking_info')
// //         .where('Tutor_Email', isEqualTo: tutorEmail)
// //         .where('timeslot', isEqualTo: timeslot)
// //         .where('status', isEqualTo: 'Panding')
// //         .get();

// //     for (var doc in querySnapshot.docs) {
// //       // Update booking status in the booking document.
// //       await doc.reference.update({'status': newStatus});

// //       // Retrieve the student email from the booking document.
// //       String studentEmail = doc.get('Student_Email');

// //       // Add a notification document with both Tutor_Email and Student_Email.
      
// //        // Depending on the newStatus, add a notification with a different notification_type.
// //       if (newStatus == 'Cancelled') {
// //         await _firestore.collection('Notifications').add({
// //           'email': tutorEmail,
// //           'message': "You have rejected  session with $studentEmail on $timeslot don't reject.You may gat fine",
// //           'timestamp': DateTime.now().toIso8601String(),
// //         });

// //         await _firestore.collection('Notifications').add({
// //           'email': studentEmail,
// //           'message':"Sorry $tutorEmail has rejected  your request  your amount will return back soon..",
// //           'timestamp': DateTime.now().toIso8601String(),
// //         });

// //       } else if (newStatus == 'Confirmed') {

// //         await _firestore.collection('Notifications').add({
// //           'email': tutorEmail,
// //           'message': "Thank you,You have Confirmed session with $studentEmail on $timeslot",
// //           'timestamp': DateTime.now().toIso8601String(),
// //         });

// //         await _firestore.collection('Notifications').add({
// //           'email': studentEmail,
// //           'message': "You request is acepted by $tutorEmail, you will get appointement on $timeslot",
// //           'timestamp': DateTime.now().toIso8601String(),
// //         });


// //       }
// //     }

// //     // If accepting the booking, update Tutor_Sessions availability (set slot to "Booked").
// //     if (newStatus == 'Confirmed') {
// //       // Expect timeslot to be "date slot", where the first part is the date.
// //       List<String> parts = timeslot.split(' ');
// //       if (parts.isNotEmpty) {
// //         String date = parts[0];
// //         // The remainder of the timeslot string is the slot.
// //         String slot = timeslot.substring(date.length).trim();
// //         await _firestore.collection('Tutor_Sessions').doc(tutorEmail).update({
// //           'availability.$date.$slot': 'Booked'
// //         });
// //       }
// //     }

// //     // Refresh the tutor availability data.
// //     await _fetchAvailability();
// //   }

// //   /// Display a pop-up dialog when the tutor taps the pending button.
// //   void _showPendingDialog({
// //     required String date,
// //     required String slot,
// //   }) {
// //     String timeslot = "$date $slot";
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text("Pending Request"),
// //           content: Text("Plz accept the class soon. Student is waiting for your confirmation."),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context); // Cancel: simply close the dialog.
// //               },
// //               child: Text("Cancel"),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 // Reject: update status to "Cancelled"
// //                 if (currentTutorEmail != null) {
// //                   await _updateBookingStatus(
// //                     tutorEmail: currentTutorEmail!,
// //                     timeslot: timeslot,
// //                     newStatus: 'Cancelled',
// //                   );
// //                 }
// //                 Navigator.pop(context);
// //               },
// //               child: Text("Reject"),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 // Accept: update status to "Confirmed"
// //                 if (currentTutorEmail != null) {
// //                   await _updateBookingStatus(
// //                     tutorEmail: currentTutorEmail!,
// //                     timeslot: timeslot,
// //                     newStatus: 'Confirmed',
// //                   );
// //                 }
// //                 Navigator.pop(context);
// //               },
// //               child: Text("Accept"),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   /// Convert a date string (expected format "yyyy-MM-dd") to its corresponding day of the week.
// //   String _getDayOfWeek(String dateString) {
// //     try {
// //       DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
// //       return DateFormat('EEEE').format(date); // e.g., "Monday"
// //     } catch (e) {
// //       return "";
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (currentTutorEmail == null || tutorAvailability[currentTutorEmail!] == null) {
// //       return Scaffold(
// //         appBar: AppBar(
// //           title: Text('Booking Requests'),
// //           centerTitle: true,
// //         ),
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     // Get the current tutor's availability.
// //     Map<String, Map<String, String>> currentAvailability = tutorAvailability[currentTutorEmail!]!;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Booking Requests'),
// //         centerTitle: true,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           children: [
// //             // Informational message at the top.
// //             Container(
// //               padding: const EdgeInsets.all(12.0),
// //               decoration: BoxDecoration(
// //                 color: Colors.lightBlueAccent.withOpacity(0.3),
// //                 borderRadius: BorderRadius.circular(8.0),
// //               ),
// //               child: Text(
// //                 'Please confirm the class by accepting pending requests; otherwise, you may incur a fine.',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w500,
// //                   color: Colors.blue[900],
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //             SizedBox(height: 16.0),
// //             // Expanded list of dates and time slots.
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: currentAvailability.keys.length,
// //                 itemBuilder: (context, index) {
// //                   String date = currentAvailability.keys.elementAt(index);
// //                   Map<String, String> slots = currentAvailability[date]!;

// //                   // Filter slots to show only those with status "Requested" or "Booked"
// //                   var filteredSlots = slots.entries.where((entry) {
// //                     return entry.value == 'Requested' || entry.value == 'Booked';
// //                   }).toList();

// //                   if (filteredSlots.isEmpty) {
// //                     return SizedBox.shrink();
// //                   }

// //                   return Card(
// //                     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12.0),
// //                     ),
// //                     elevation: 4,
// //                     child: ExpansionTile(
// //                       title: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             date,
// //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                           ),
// //                           SizedBox(height: 2),
// //                           Text(
// //                             _getDayOfWeek(date),
// //                             style: TextStyle(fontSize: 12, color: Colors.grey[700]),
// //                           ),
// //                         ],
// //                       ),
// //                       children: filteredSlots.map((entry) {
// //                         if (entry.value == 'Booked') {
// //                           // For a "Booked" slot, display a chip with "Confirmed".
// //                           return ListTile(
// //                             leading: Icon(Icons.access_time, color: Colors.blue),
// //                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
// //                             trailing: Chip(
// //                               label: Text(
// //                                 'Confirmed',
// //                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                               ),
// //                               backgroundColor: Colors.green,
// //                             ),
// //                           );
// //                         }
// //                         else if (entry.value == 'Cancelled') {
// //                           return ListTile(
// //                             leading: Icon(Icons.cancel, color: Colors.red),
// //                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
// //                             trailing: Chip(
// //                               label: Text(
// //                                 'Rejected',
// //                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                               ),
// //                               backgroundColor: Colors.red,
// //                             ),
// //                           );
// //                         }
// //                          else {
// //                           // For a "Requested" slot, show a "Pending" button.
// //                           return ListTile(
// //                             leading: Icon(Icons.access_time, color: Colors.blue),
// //                             title: Text(entry.key, style: TextStyle(fontSize: 16)),
// //                             trailing: ElevatedButton(
// //                               child: Text("Pending"),
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: Colors.orange,
// //                               ),
// //                               onPressed: () {
// //                                 _showPendingDialog(
// //                                   date: date,
// //                                   slot: entry.key,
// //                                 );
// //                               },
// //                             ),
// //                           );
// //                         }
// //                       }).toList(),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:intl/intl.dart';
// // import 'package:tutorconnect_app/models/messsage.dart'; // For formatting dates

// // class BookingRequestsPage extends StatefulWidget {
// //   @override
// //   _BookingRequestsPageState createState() => _BookingRequestsPageState();
// // }

// // class _BookingRequestsPageState extends State<BookingRequestsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   /// Now each tutor email maps to a Map of date → (time slot → status)
// //   Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

// //   String? currentTutorEmail;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchAvailability();
// //   }

// //   /// Fetch availability for the current tutor.
// //   Future<void> _fetchAvailability() async {
// //     User? currentUser = _auth.currentUser;
// //     if (currentUser != null) {
// //       String tutorEmail = currentUser.email!;
// //       currentTutorEmail = tutorEmail;

// //       final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

// //       if (doc.exists && doc.data()?['availability'] != null) {
// //         Map<String, dynamic> fetchedData = doc.data()!['availability'];
// //         Map<String, Map<String, String>> formattedData = {};

// //         // For each date, convert the slots to a Map<String, String>
// //         fetchedData.forEach((date, slots) {
// //           Map<String, String> parsedSlots = {};
// //           (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// //             parsedSlots[timeSlot] = status;
// //           });
// //           formattedData[date] = parsedSlots;
// //         });

// //         setState(() {
// //           // Save the availability data under the tutor's email
// //           tutorAvailability[tutorEmail] = formattedData;
// //         });
// //       }
// //     } else {
// //       print("No user is logged in.");
// //     }
// //   }

// //   /// Update the booking status in Booking_info and add a notification.
// //   Future<void> _updateBookingStatus({
// //     required String tutorEmail,
// //     required String timeslot, // Concatenated as "date slot" (e.g., "2025-02-05 10:00 AM - 11:00 AM")
// //     required String newStatus, // "Cancelled" or "Confirmed"
// //   }) async {
// //     // Query Booking_info documents matching Tutor_Email, timeslot and status "Panding"
// //     QuerySnapshot querySnapshot = await _firestore
// //         .collection('Booking_info')
// //         .where('Tutor_Email', isEqualTo: tutorEmail)
// //         .where('timeslot', isEqualTo: timeslot)
// //         .where('status', isEqualTo: 'Panding')
// //         .get();

// //     for (var doc in querySnapshot.docs) {
// //       await doc.reference.update({'status': newStatus});
// //     }

// //     // For Accept, update the Tutor_Sessions availability: change "Requested" to "Booked"
// //     if (newStatus == 'Confirmed') {
// //       // We expect timeslot to be "date slot" (e.g., "2025-02-05 10:00 AM - 11:00 AM")
// //       List<String> parts = timeslot.split(' ');
// //       if (parts.isNotEmpty) {
// //         String date = parts[0];
// //         // The remainder of the string is the time slot
// //         String slot = timeslot.substring(date.length).trim();
// //         await _firestore.collection('Tutor_Sessions').doc(tutorEmail).update({
// //           'availability.$date.$slot': 'Booked'
// //         });
// //       }
// //     }

// //     // Add a notification (the Accept and Reject actions do not display a separate message)
// //     await _firestore.collection('Notifications').add({
// //       'email': tutorEmail,
// //       'message':"",
// //       'timestamp': DateTime.now().toIso8601String(),
// //     });

// //     await _firestore.collection('Notifications').add({
// //       'Tutor_Email': tutorEmail,
// //       'timeslot': timeslot,
// //       'new_status': newStatus,
// //       'timestamp': DateTime.now().toIso8601String(),
// //     });

// //     // Refresh availability after the update.
// //     await _fetchAvailability();
// //   }

// //   /// Show the pop-up dialog when the tutor taps on the pending button.
// //   void _showPendingDialog({
// //     required String date,
// //     required String slot,
// //     required String studentEmail, // For demonstration, a hardcoded value is used.
// //   }) {
// //     String timeslot = "$date $slot";
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text("Pending Request"),
// //           content: Text("Plz accept the class soon. Student is waiting for your confirmation."),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context); // Simply close the dialog.
// //               },
// //               child: Text("Cancel"),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 // Reject: update status to "Cancelled"
// //                 if (currentTutorEmail != null) {
// //                   await _updateBookingStatus(
// //                     tutorEmail: currentTutorEmail!,
// //                     timeslot: timeslot,
// //                     newStatus: 'Cancelled',
// //                   );
// //                 }
// //                 Navigator.pop(context);
// //               },
// //               child: Text("Reject"),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 // Accept: update status to "Confirmed"
// //                 if (currentTutorEmail != null) {
// //                   await _updateBookingStatus(
// //                     tutorEmail: currentTutorEmail!,
// //                     timeslot: timeslot,
// //                     newStatus: 'Confirmed',
// //                   );
// //                 }
// //                 Navigator.pop(context);
// //               },
// //               child: Text("Accept"),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   /// Given a date string (format: "yyyy-MM-dd"), return the day of the week.
// //   String _getDayOfWeek(String dateString) {
// //     try {
// //       DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
// //       return DateFormat('EEEE').format(date); // e.g., "Monday"
// //     } catch (e) {
// //       return "";
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Show a loading indicator if there's no tutor email or data yet.
// //     if (currentTutorEmail == null ||
// //         tutorAvailability[currentTutorEmail!] == null) {
// //       return Scaffold(
// //         appBar: AppBar(
// //           title: Text('Booking Requests'),
// //           centerTitle: true,
// //         ),
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     // Get the current tutor's availability.
// //     Map<String, Map<String, String>> currentAvailability = tutorAvailability[currentTutorEmail!]!;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Booking Requests'),
// //         centerTitle: true,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           children: [
// //             // Informational message at the top.
// //             Container(
// //               padding: const EdgeInsets.all(12.0),
// //               decoration: BoxDecoration(
// //                 color: Colors.lightBlueAccent.withOpacity(0.3),
// //                 borderRadius: BorderRadius.circular(8.0),
// //               ),
// //               child: Text(
// //                 'Please confirm the class by accepting pending requests; otherwise, you may incur a fine.',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w500,
// //                   color: Colors.blue[900],
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //             SizedBox(height: 16.0),
// //             // Expanded list of dates and time slots.
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: currentAvailability.keys.length,
// //                 itemBuilder: (context, index) {
// //                   String date = currentAvailability.keys.elementAt(index);
// //                   Map<String, String> slots = currentAvailability[date]!;

// //                   // Filter to show only slots with status "Requested" or "Booked"
// //                   var filteredSlots = slots.entries.where((entry) {
// //                     return entry.value == 'Requested' || entry.value == 'Booked';
// //                   }).toList();

// //                   if (filteredSlots.isEmpty) {
// //                     return SizedBox.shrink();
// //                   }

// //                   return Card(
// //                     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12.0),
// //                     ),
// //                     elevation: 4,
// //                     child: ExpansionTile(
// //                       title: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             date,
// //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                           ),
// //                           SizedBox(height: 2),
// //                           Text(
// //                             _getDayOfWeek(date),
// //                             style: TextStyle(fontSize: 12, color: Colors.grey[700]),
// //                           ),
// //                         ],
// //                       ),
// //                       children: filteredSlots.map((entry) {
// //                         if (entry.value == 'Booked') {
// //                           // For a "Booked" slot, show a chip with "Confirmed".
// //                           return ListTile(
// //                             leading: Icon(
// //                               Icons.access_time,
// //                               color: Colors.blue,
// //                             ),
// //                             title: Text(
// //                               entry.key,
// //                               style: TextStyle(fontSize: 16),
// //                             ),
// //                             trailing: Chip(
// //                               label: Text(
// //                                 'Confirmed',
// //                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                               ),
// //                               backgroundColor: Colors.green,
// //                             ),
// //                           );
// //                         } else {
// //                           // For a "Requested" slot, show a "Pending" button.
// //                           return ListTile(
// //                             leading: Icon(
// //                               Icons.access_time,
// //                               color: Colors.blue,
// //                             ),
// //                             title: Text(
// //                               entry.key,
// //                               style: TextStyle(fontSize: 16),
// //                             ),
// //                             trailing: ElevatedButton(
// //                               child: Text("Pending"),
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: Colors.orange,
// //                               ),
// //                               onPressed: () {
// //                                 // For demonstration, using a hardcoded student email.
// //                                 String studentEmail = "student@example.com";
// //                                 _showPendingDialog(
// //                                   date: date,
// //                                   slot: entry.key,
// //                                   studentEmail: studentEmail,
// //                                 );
// //                               },
// //                             ),
// //                           );
// //                         }
// //                       }).toList(),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';

// // // class BookingRequestsPage extends StatefulWidget {
// // //   @override
// // //   _BookingRequestsPageState createState() => _BookingRequestsPageState();
// // // }

// // // class _BookingRequestsPageState extends State<BookingRequestsPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   Map<String, Map<String, String>> tutorAvailability = {};

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchAvailability();
// // //   }

// // //   Future<void> _fetchAvailability() async {
// // //     // Get current user's email
// // //     User? currentUser = _auth.currentUser;
// // //     if (currentUser != null) {
// // //       String tutorEmail = currentUser.email!;  // Current user's email

// // //       // Fetch tutor availability based on the email
// // //       final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

// // //       if (doc.exists && doc.data()?['availability'] != null) {
// // //         Map<String, dynamic> fetchedData = doc.data()?['availability'];
// // //         Map<String, Map<String, String>> formattedData = {};

// // //         fetchedData.forEach((date, slots) {
// // //           Map<String, String> parsedSlots = {};
// // //           (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// // //             parsedSlots[timeSlot] = status;
// // //           });
// // //           formattedData[date] = parsedSlots;
// // //         });

// // //         setState(() {
// // //           tutorAvailability = formattedData;
// // //         });
// // //       }
// // //     } else {
// // //       // Handle the case if the user is not logged in
// // //       print("No user is logged in.");
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Booking Requests'),
// // //       ),
// // //       body: tutorAvailability.isEmpty
// // //           ? Center(child: CircularProgressIndicator())
// // //           : ListView.builder(
// // //               itemCount: tutorAvailability.keys.length,
// // //               itemBuilder: (context, index) {
// // //                 String date = tutorAvailability.keys.elementAt(index);
// // //                 Map<String, String> slots = tutorAvailability[date]!;

// // //                 // Filter slots to only show Requested or Booked statuses
// // //                 var filteredSlots = slots.entries
// // //                     .where((entry) => entry.value == 'Requested' || entry.value == 'Booked')
// // //                     .toList();

// // //                 return ExpansionTile(
// // //                   title: Text('Date: $date'),
// // //                   children: filteredSlots.map((entry) {
// // //                     return ListTile(
// // //                       title: Text('Time: ${entry.key}'),
// // //                       subtitle: Text('Status: ${entry.value}'),
// // //                       trailing: entry.value == 'Booked'
// // //                           ? Icon(Icons.check_circle, color: Colors.green)  // Green for Booked
// // //                           : entry.value == 'Requested'
// // //                               ? Icon(Icons.access_time, color: Colors.yellow)  // Yellow for Requested
// // //                               : null,
// // //                     );
// // //                   }).toList(),
// // //                 );
// // //               },
// // //             ),
// // //     );
// // //   }
// // // }


// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';

// // // class BookingRequestsPage extends StatefulWidget {
// // //   @override
// // //   _BookingRequestsPageState createState() => _BookingRequestsPageState();
// // // }

// // // class _BookingRequestsPageState extends State<BookingRequestsPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   Map<String, Map<String, String>> tutorAvailability = {};

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchAvailability();
// // //   }

// // //   Future<void> _fetchAvailability() async {
// // //     // Get current user's email
// // //     User? currentUser = _auth.currentUser;
// // //     if (currentUser != null) {
// // //       String tutorEmail = currentUser.email!;  // Current user's email

// // //       // Fetch tutor availability based on the email
// // //       final doc = await _firestore.collection('Tutor_Sessions').doc(tutorEmail).get();

// // //       if (doc.exists && doc.data()?['availability'] != null) {
// // //         Map<String, dynamic> fetchedData = doc.data()?['availability'];
// // //         Map<String, Map<String, String>> formattedData = {};

// // //         fetchedData.forEach((date, slots) {
// // //           Map<String, String> parsedSlots = {};
// // //           (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// // //             parsedSlots[timeSlot] = status;
// // //           });
// // //           formattedData[date] = parsedSlots;
// // //         });

// // //         setState(() {
// // //           tutorAvailability = formattedData;
// // //         });
// // //       }
// // //     } else {
// // //       // Handle the case if the user is not logged in
// // //       print("No user is logged in.");
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Booking Requests'),
// // //       ),
// // //       body: tutorAvailability.isEmpty
// // //           ? Center(child: CircularProgressIndicator())
// // //           : ListView.builder(
// // //               itemCount: tutorAvailability.keys.length,
// // //               itemBuilder: (context, index) {
// // //                 String date = tutorAvailability.keys.elementAt(index);
// // //                 Map<String, String> slots = tutorAvailability[date]!;

// // //                 return ExpansionTile(
// // //                   title: Text('Date: $date'),
// // //                   children: slots.entries.map((entry) {
// // //                     return ListTile(
// // //                       title: Text('Time: ${entry.key}'),
// // //                       subtitle: Text('Status: ${entry.value}'),
// // //                       trailing: entry.value == 'Available'
// // //                           ? Icon(Icons.check_circle, color: Colors.green)
// // //                           : entry.value == 'Booked'
// // //                               ? Icon(Icons.block, color: Colors.red)
// // //                               : Icon(Icons.access_time, color: Colors.orange),
// // //                     );
// // //                   }).toList(),
// // //                 );
// // //               },
// // //             ),
// // //     );
// // //   }
// // // }
