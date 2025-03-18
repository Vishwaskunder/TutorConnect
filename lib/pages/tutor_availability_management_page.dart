import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TutorAvailability extends StatefulWidget {
  @override
  _TutorAvailabilityState createState() => _TutorAvailabilityState();
}

class _TutorAvailabilityState extends State<TutorAvailability> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userEmail = '';
  String username = '';
  String subCategory = '';

  @override
  void initState() {
    super.initState();
    _loadTutorData();
  }

  /// Loads tutor's credentials and updates Tutor_Sessions.
  Future<void> _loadTutorData() async {
    final user = _auth.currentUser;
    if (user != null) {
      userEmail = user.email ?? '';

      final querySnapshot = await _firestore
          .collection('tutor_credential')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final tutorDoc = querySnapshot.docs.first;
        final data = tutorDoc.data();
        username = data['username'] ?? '';
        subCategory = data['subCategory'] ?? '';

        await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
          'username': username,
          'subCategory': subCategory,
          'email': userEmail,
        }, SetOptions(merge: true));

        await _removeOldSlots();
      }

      setState(() {});
    }
  }

  /// Removes outdated slots (before today) from Firestore.
  Future<void> _removeOldSlots() async {
    final doc = await _firestore.collection('Tutor_Sessions').doc(userEmail).get();
    if (doc.exists && doc.data()?['availability'] != null) {
      Map<String, dynamic> fetchedData = doc.data()?['availability'];
      Map<String, dynamic> updatedData = Map.from(fetchedData);
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      updatedData.removeWhere((date, slots) => date.compareTo(today) < 0);

      await _firestore.collection('Tutor_Sessions').doc(userEmail).update({
        'availability': updatedData,
      });
    }
  }

  Future<void> _toggleSlot(String date, String slot, Map<String, Map<String, String>> currentSlots) async {
    Map<String, Map<String, String>> updatedSlots = currentSlots.map(
      (key, value) => MapEntry(key, Map<String, String>.from(value)),
    );

    if (!updatedSlots.containsKey(date)) {
      updatedSlots[date] = {};
    }

    if (updatedSlots[date]!.containsKey(slot)) {
      String? currentStatus = updatedSlots[date]![slot];

      if (currentStatus == "Available") {
        updatedSlots[date]!.remove(slot);

        if (updatedSlots[date]!.isEmpty) {
          updatedSlots.remove(date);
        }

        // Use Firestore's update method to remove the field
        await _firestore.collection('Tutor_Sessions').doc(userEmail).update({
          'availability.$date.$slot': FieldValue.delete(),
        });

        return; // Exit after removing
      } else {
        return; // Prevent modification if "Requested" or "Booked"
      }
    } else {
      updatedSlots[date]![slot] = "Available";

      // Update Firestore with the new slot
      await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
        'availability': updatedSlots,
      }, SetOptions(merge: true));
    }
  }
  /// Generates time slots for the given date.
  List<String> generateTimeSlots(String selectedDate) {
    List<String> allSlots = [
      "09:00-10:00", "10:00-11:00", "11:00-12:00",
      "14:00-15:00", "15:00-16:00", "16:00-17:00",
      "17:00-18:00", "18:00-19:00", "19:00-20:00",
    ];

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DateTime now = DateTime.now();

    if (selectedDate == today) {
      int currentHour = now.hour;
      return allSlots.where((slot) {
        int slotHour = int.parse(slot.split(':')[0]);
        return slotHour > currentHour;
      }).toList();
    }

    return allSlots;
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Manage Availability")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    DateTime now = DateTime.now();
    List<String> next7Days = List.generate(7, (index) {
      return DateFormat('yyyy-MM-dd').format(now.add(Duration(days: index)));
    });

    return Scaffold(
      appBar: AppBar(title: Text("Manage Availability")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('Tutor_Sessions').doc(userEmail).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          Map<String, Map<String, String>> currentSlots = {};
          if (snapshot.data != null && snapshot.data!.exists) {
            var data = snapshot.data!.data();
            if (data is Map<String, dynamic> && data.containsKey('availability')) {
              Map<String, dynamic> availabilityData = data['availability'];
              availabilityData.forEach((date, slots) {
                Map<String, String> parsedSlots = {};
                (slots as Map<String, dynamic>).forEach((timeSlot, status) {
                  parsedSlots[timeSlot] = status;
                });
                currentSlots[date] = parsedSlots;
              });
            }
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Select your available slots for the week:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: next7Days.length,
                  itemBuilder: (context, index) {
                    String date = next7Days[index];
                    List<String> slotsForDay = generateTimeSlots(date);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ExpansionTile(
                        title: Text(
                          "${DateFormat('EEE, MMM d').format(DateTime.parse(date))}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Wrap(
                            spacing: 10,
                            children: slotsForDay.map((slot) {
                              String status = currentSlots[date]?[slot] ?? "Unavailable";
                              bool isSelected = status == "Available";
                              bool isRequested = status == "Requested";
                              bool isBooked = status == "Booked";
                              bool isCancelled=status=="Cancelled";

                              Color slotColor = Colors.white;
                              if (isSelected) slotColor = Colors.green;
                              if (isRequested) slotColor = Colors.orange;
                              if (isBooked) slotColor = Colors.purple;
                              if (isCancelled) slotColor=Colors.red;

                              return GestureDetector(
                                onTap: () {
                                  if (!isRequested && !isBooked) {
                                    _toggleSlot(date, slot, currentSlots);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: slotColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: (isRequested || isBooked) ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:intl/intl.dart';

// // class TutorAvailability extends StatefulWidget {
// //   @override
// //   _TutorAvailabilityState createState() => _TutorAvailabilityState();
// // }

// // class _TutorAvailabilityState extends State<TutorAvailability> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
// //   String userEmail = '';
// //   String username = '';
// //   String subCategory = ''; // New field from tutor_credential

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadTutorData();
// //   }

// //   /// Loads the tutor’s credentials (email, username, subCategory) by querying
// //   /// the tutor_credential collection (since documents are created with .add())
// //   /// and then updates Tutor_Sessions.
// //   Future<void> _loadTutorData() async {
// //     final user = _auth.currentUser;
// //     if (user != null) {
// //       userEmail = user.email ?? '';

// //       // Query the tutor_credential collection using the email field.
// //       final querySnapshot = await _firestore
// //           .collection('tutor_credential') // ensure this matches your collection name exactly.
// //           .where('email', isEqualTo: userEmail)
// //           .get();

// //       if (querySnapshot.docs.isNotEmpty) {
// //         final tutorDoc = querySnapshot.docs.first;
// //         final data = tutorDoc.data();
// //         username = data['username'] ?? '';
// //         subCategory = data['subCategory'] ?? '';

// //         // Debug prints to verify fetched data.
// //         print("Fetched Tutor Data: username='$username', subCategory='$subCategory'");

// //         // Update Tutor_Sessions immediately with the credentials.
// //         await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
// //           'username': username,
// //           'subCategory': subCategory,
// //           'email': userEmail,
// //           'student_email': ""
// //         }, SetOptions(merge: true));

// //         // Remove outdated slots once on page load.
// //         await _removeOldSlots();
// //       }
// //       // Trigger a rebuild now that we have userEmail, username, and subCategory.
// //       setState(() {});
// //     }
// //   }

// //   /// Removes outdated availability (dates before today) directly from Firestore.
// //   Future<void> _removeOldSlots() async {
// //     final doc = await _firestore.collection('Tutor_Sessions').doc(userEmail).get();
// //     if (doc.exists && doc.data()?['availability'] != null) {
// //       Map<String, dynamic> fetchedData = doc.data()?['availability'];
// //       Map<String, dynamic> updatedData = Map.from(fetchedData);
// //       String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       // Remove keys (dates) older than today.
// //       updatedData.removeWhere((date, slots) => date.compareTo(today) < 0);

// //       await _firestore.collection('Tutor_Sessions').doc(userEmail).update({
// //         'availability': updatedData,
// //       });
// //     }
// //   }

// //   /// Toggle the given slot by reading the current availability from Firestore and
// //   /// updating the document. We work on a copy so that the stream updates the UI.
// //   Future<void> _updateSlot(String date, String slot, Map<String, Map<String, String>> currentSlots) async {
// //     // Create a deep copy of the current availability.
// //     Map<String, Map<String, String>> updatedSlots = currentSlots.map(
// //       (key, value) => MapEntry(key, Map<String, String>.from(value)),
// //     );

// //     // Toggle the slot.
// //     if (updatedSlots.containsKey(date)) {
// //       if (updatedSlots[date]![slot] == "Available") {
// //         // Deselect: Remove the slot.
// //         updatedSlots[date]!.remove(slot);
// //         if (updatedSlots[date]!.isEmpty) {
// //           updatedSlots.remove(date);
// //         }
// //       } else {
// //         // Mark the slot as available.
// //         updatedSlots[date]![slot] = "Available";
// //       }
// //     } else {
// //       updatedSlots[date] = {slot: "Available"};
// //     }

// //     // Update Tutor_Sessions with both username and subCategory.
// //     await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
// //       'username': username,
// //       'subCategory': subCategory,
// //       'email': userEmail,
// //       'student_email': "",
// //       'availability': updatedSlots,
// //     }, SetOptions(merge: true));
// //   }

// //   /// Generates the list of possible time slots for the given date.
// //   List<String> generateTimeSlots(String selectedDate) {
// //     List<String> allSlots = [
// //       "09:00-10:00",
// //       "10:00-11:00",
// //       "11:00-12:00",
// //       "14:00-15:00",
// //       "15:00-16:00",
// //       "16:00-17:00",
// //       "17:00-18:00",
// //       "18:00-19:00",
// //       "19:00-20:00",
// //     ];

// //     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// //     DateTime now = DateTime.now();

// //     // If the selected date is today, filter out slots that have already passed.
// //     if (selectedDate == today) {
// //       int currentHour = now.hour;
// //       return allSlots.where((slot) {
// //         int slotHour = int.parse(slot.split(':')[0]);
// //         return slotHour > currentHour;
// //       }).toList();
// //     }

// //     return allSlots;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // While we haven't loaded the tutor's email/username/subCategory, show a loader.
// //     if (userEmail.isEmpty) {
// //       return Scaffold(
// //         appBar: AppBar(title: Text("Manage Availability")),
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     DateTime now = DateTime.now();
// //     // Generate dates for the next 7 days.
// //     List<String> next7Days = List.generate(7, (index) {
// //       return DateFormat('yyyy-MM-dd').format(now.add(Duration(days: index)));
// //     });

// //     return Scaffold(
// //       appBar: AppBar(title: Text("Manage Availability")),
// //       body: StreamBuilder<DocumentSnapshot>(
// //         stream: _firestore.collection('Tutor_Sessions').doc(userEmail).snapshots(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           }
// //           if (snapshot.hasError) {
// //             return Center(child: Text("Error: ${snapshot.error}"));
// //           }

// //           // Parse Firestore data into a Map<String, Map<String, String>>
// //           Map<String, Map<String, String>> currentSlots = {};
// //           if (snapshot.data != null && snapshot.data!.exists) {
// //             var data = snapshot.data!.data();
// //             if (data is Map<String, dynamic> && data.containsKey('availability')) {
// //               Map<String, dynamic> availabilityData = data['availability'];
// //               availabilityData.forEach((date, slots) {
// //                 Map<String, String> parsedSlots = {};
// //                 (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// //                   parsedSlots[timeSlot] = status;
// //                 });
// //                 currentSlots[date] = parsedSlots;
// //               });
// //             }
// //           }

// //           return Column(
// //             children: [
// //               Padding(
// //                 padding: EdgeInsets.all(10),
// //                 child: Text(
// //                   "Select your available slots for the week:",
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               Expanded(
// //                 child: ListView.builder(
// //                   itemCount: next7Days.length,
// //                   itemBuilder: (context, index) {
// //                     String date = next7Days[index];
// //                     List<String> slotsForDay = generateTimeSlots(date);

// //                     return Card(
// //                       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                       child: ExpansionTile(
// //                         title: Text(
// //                           "${DateFormat('EEE, MMM d').format(DateTime.parse(date))}",
// //                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                         ),
// //                         children: [
// //                           Wrap(
// //                             spacing: 10,
// //                             children: slotsForDay.map((slot) {
// //                               // Determine the current status for this slot.
// //                               String status = currentSlots[date]?[slot] ?? "Unavailable";
// //                               bool isSelected = status == "Available";
// //                               bool isRequested = status == "Requested";
// //                               bool isBooked = status == "Booked";

// //                               Color slotColor = Colors.white;
// //                               if (isSelected) slotColor = Colors.green;
// //                               if (isRequested) slotColor = Colors.orange;
// //                               if (isBooked) slotColor = Colors.purple;

// //                               return GestureDetector(
// //                                 onTap: () {
// //                                   // Allow toggling only if the slot is not requested or booked.
// //                                   if (!isRequested && !isBooked) {
// //                                     _updateSlot(date, slot, currentSlots);
// //                                   }
// //                                 },
// //                                 child: Container(
// //                                   margin: EdgeInsets.all(5),
// //                                   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// //                                   decoration: BoxDecoration(
// //                                     color: slotColor,
// //                                     borderRadius: BorderRadius.circular(10),
// //                                     border: Border.all(color: Colors.black, width: 1),
// //                                   ),
// //                                   child: Text(
// //                                     slot,
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: (isRequested || isBooked) ? Colors.white : Colors.black,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               );
// //                             }).toList(),
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }


// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:intl/intl.dart';

// // // class TutorAvailability extends StatefulWidget {
// // //   @override
// // //   _TutorAvailabilityState createState() => _TutorAvailabilityState();
// // // }

// // // class _TutorAvailabilityState extends State<TutorAvailability> {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   String userEmail = '';
// // //   String username = '';
// // //   String subCategory = ''; // New field from Tutor_credential

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadTutorData();
// // //   }

// // //   /// Loads the tutor’s credentials (email, username, subCategory) and then updates Tutor_Sessions.
// // //   Future<void> _loadTutorData() async {
// // //     final user = _auth.currentUser;
// // //     if (user != null) {
// // //       userEmail = user.email ?? '';
// // //       final tutorDoc = await _firestore
// // //           .collection('Tutor_credential')
// // //           .doc(user.uid)
// // //           .get();
// // //       if (tutorDoc.exists) {
// // //         username = tutorDoc.data()?['username'] ?? '';
// // //         subCategory = tutorDoc.data()?['subCategory'] ?? '';
// // //         // Update Tutor_Sessions immediately with the credentials.
// // //         await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
// // //           'username': username,
// // //           'subCategory': subCategory,
// // //           'email': userEmail,
// // //           'student_email': ""
// // //         }, SetOptions(merge: true));
// // //         // Remove outdated slots once on page load.
// // //         await _removeOldSlots();
// // //       }
// // //       // Trigger a rebuild now that we have userEmail, username, and subCategory.
// // //       setState(() {});
// // //     }
// // //   }

// // //   /// Removes outdated availability (dates before today) directly from Firestore.
// // //   Future<void> _removeOldSlots() async {
// // //     final doc = await _firestore.collection('Tutor_Sessions').doc(userEmail).get();
// // //     if (doc.exists && doc.data()?['availability'] != null) {
// // //       Map<String, dynamic> fetchedData = doc.data()?['availability'];
// // //       Map<String, dynamic> updatedData = Map.from(fetchedData);
// // //       String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

// // //       // Remove keys (dates) older than today.
// // //       updatedData.removeWhere((date, slots) => date.compareTo(today) < 0);

// // //       await _firestore.collection('Tutor_Sessions').doc(userEmail).update({
// // //         'availability': updatedData,
// // //       });
// // //     }
// // //   }

// // //   /// Toggle the given slot by reading the current availability from Firestore and
// // //   /// updating the document. We work on a copy so that the stream updates the UI.
// // //   Future<void> _updateSlot(String date, String slot, Map<String, Map<String, String>> currentSlots) async {
// // //     // Create a deep copy of the current availability.
// // //     Map<String, Map<String, String>> updatedSlots = currentSlots.map((key, value) =>
// // //         MapEntry(key, Map<String, String>.from(value)));

// // //     // Toggle the slot.
// // //     if (updatedSlots.containsKey(date)) {
// // //       if (updatedSlots[date]![slot] == "Available") {
// // //         // Deselect: Remove the slot.
// // //         updatedSlots[date]!.remove(slot);
// // //         if (updatedSlots[date]!.isEmpty) {
// // //           updatedSlots.remove(date);
// // //         }
// // //       } else {
// // //         // Mark the slot as available.
// // //         updatedSlots[date]![slot] = "Available";
// // //       }
// // //     } else {
// // //       updatedSlots[date] = {slot: "Available"};
// // //     }

// // //     // Update Tutor_Sessions with both username and subCategory.
// // //     await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
// // //       'username': username,
// // //       'subCategory': subCategory,
// // //       'email': userEmail,
// // //       'student_email': "",
// // //       'availability': updatedSlots,
// // //     }, SetOptions(merge: true));
// // //   }

// // //   /// Generates the list of possible time slots for the given date.
// // //   List<String> generateTimeSlots(String selectedDate) {
// // //     List<String> allSlots = [
// // //       "09:00-10:00",
// // //       "10:00-11:00",
// // //       "11:00-12:00",
// // //       "14:00-15:00",
// // //       "15:00-16:00",
// // //       "16:00-17:00",
// // //       "17:00-18:00",
// // //       "18:00-19:00",
// // //       "19:00-20:00",
// // //     ];

// // //     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// // //     DateTime now = DateTime.now();

// // //     // If the selected date is today, filter out slots that have already passed.
// // //     if (selectedDate == today) {
// // //       int currentHour = now.hour;
// // //       return allSlots.where((slot) {
// // //         int slotHour = int.parse(slot.split(':')[0]);
// // //         return slotHour > currentHour;
// // //       }).toList();
// // //     }

// // //     return allSlots;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // While we haven't loaded the tutor's email/username/subCategory, show a loader.
// // //     if (userEmail.isEmpty) {
// // //       return Scaffold(
// // //         appBar: AppBar(title: Text("Manage Availability")),
// // //         body: Center(child: CircularProgressIndicator()),
// // //       );
// // //     }

// // //     DateTime now = DateTime.now();
// // //     // Generate dates for the next 7 days.
// // //     List<String> next7Days = List.generate(7, (index) {
// // //       return DateFormat('yyyy-MM-dd').format(now.add(Duration(days: index)));
// // //     });

// // //     return Scaffold(
// // //       appBar: AppBar(title: Text("Manage Availability")),
// // //       body: StreamBuilder<DocumentSnapshot>(
// // //         stream: _firestore.collection('Tutor_Sessions').doc(userEmail).snapshots(),
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             return Center(child: CircularProgressIndicator());
// // //           }
// // //           if (snapshot.hasError) {
// // //             return Center(child: Text("Error: ${snapshot.error}"));
// // //           }

// // //           // Parse Firestore data into a Map<String, Map<String, String>>
// // //           Map<String, Map<String, String>> currentSlots = {};
// // //           if (snapshot.data != null && snapshot.data!.exists) {
// // //             var data = snapshot.data!.data();
// // //             if (data is Map<String, dynamic> && data.containsKey('availability')) {
// // //               Map<String, dynamic> availabilityData = data['availability'];
// // //               availabilityData.forEach((date, slots) {
// // //                 Map<String, String> parsedSlots = {};
// // //                 (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// // //                   parsedSlots[timeSlot] = status;
// // //                 });
// // //                 currentSlots[date] = parsedSlots;
// // //               });
// // //             }
// // //           }

// // //           return Column(
// // //             children: [
// // //               Padding(
// // //                 padding: EdgeInsets.all(10),
// // //                 child: Text(
// // //                   "Select your available slots for the week:",
// // //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //                 ),
// // //               ),
// // //               Expanded(
// // //                 child: ListView.builder(
// // //                   itemCount: next7Days.length,
// // //                   itemBuilder: (context, index) {
// // //                     String date = next7Days[index];
// // //                     List<String> slotsForDay = generateTimeSlots(date);

// // //                     return Card(
// // //                       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// // //                       child: ExpansionTile(
// // //                         title: Text(
// // //                           "${DateFormat('EEE, MMM d').format(DateTime.parse(date))}",
// // //                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                         ),
// // //                         children: [
// // //                           Wrap(
// // //                             spacing: 10,
// // //                             children: slotsForDay.map((slot) {
// // //                               // Determine the current status for this slot.
// // //                               String status = currentSlots[date]?[slot] ?? "Unavailable";
// // //                               bool isSelected = status == "Available";
// // //                               bool isRequested = status == "Requested";
// // //                               bool isBooked = status == "Booked";

// // //                               Color slotColor = Colors.white;
// // //                               if (isSelected) slotColor = Colors.green;
// // //                               if (isRequested) slotColor = Colors.orange;
// // //                               if (isBooked) slotColor = Colors.purple;

// // //                               return GestureDetector(
// // //                                 onTap: () {
// // //                                   // Allow toggling only if the slot is not requested or booked.
// // //                                   if (!isRequested && !isBooked) {
// // //                                     _updateSlot(date, slot, currentSlots);
// // //                                   }
// // //                                 },
// // //                                 child: Container(
// // //                                   margin: EdgeInsets.all(5),
// // //                                   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// // //                                   decoration: BoxDecoration(
// // //                                     color: slotColor,
// // //                                     borderRadius: BorderRadius.circular(10),
// // //                                     border: Border.all(color: Colors.black, width: 1),
// // //                                   ),
// // //                                   child: Text(
// // //                                     slot,
// // //                                     style: TextStyle(
// // //                                       fontSize: 16,
// // //                                       fontWeight: FontWeight.bold,
// // //                                       color: (isRequested || isBooked) ? Colors.white : Colors.black,
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                               );
// // //                             }).toList(),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }






// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:intl/intl.dart';

// // // class TutorAvailability extends StatefulWidget {
// // //   @override
// // //   _TutorAvailabilityState createState() => _TutorAvailabilityState();
// // // }

// // // class _TutorAvailabilityState extends State<TutorAvailability> {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   String userEmail = '';
// // //   String username = '';

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadTutorData();
// // //   }

// // //   /// Loads the tutor’s credentials (email & username) and then cleans up outdated slots.
// // //   Future<void> _loadTutorData() async {
// // //     final user = _auth.currentUser;
// // //     if (user != null) {
// // //       userEmail = user.email ?? '';
// // //       final tutorDoc = await _firestore
// // //           .collection('Tutor_credential')
// // //           .doc(user.uid)
// // //           .get();
// // //       if (tutorDoc.exists) {
// // //         username = tutorDoc.data()?['username'] ?? '';
// // //         // Remove outdated slots once on page load.
// // //         await _removeOldSlots();
// // //       }
// // //       // Trigger a rebuild now that we have userEmail/username.
// // //       setState(() {});
// // //     }
// // //   }

// // //   /// Removes outdated availability (dates before today) directly from Firestore.
// // //   Future<void> _removeOldSlots() async {
// // //     final doc = await _firestore.collection('Tutor_Sessions').doc(userEmail).get();
// // //     if (doc.exists && doc.data()?['availability'] != null) {
// // //       Map<String, dynamic> fetchedData = doc.data()?['availability'];
// // //       Map<String, dynamic> updatedData = Map.from(fetchedData);
// // //       String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

// // //       // Remove keys (dates) older than today.
// // //       updatedData.removeWhere((date, slots) => date.compareTo(today) < 0);

// // //       await _firestore.collection('Tutor_Sessions').doc(userEmail).update({
// // //         'availability': updatedData,
// // //       });
// // //     }
// // //   }

// // //   /// Toggle the given slot by reading the current availability from Firestore and
// // //   /// updating the document. We work on a copy so that the stream updates the UI.
// // //   Future<void> _updateSlot(String date, String slot, Map<String, Map<String, String>> currentSlots) async {
// // //     // Create a deep copy of the current availability.
// // //     Map<String, Map<String, String>> updatedSlots = currentSlots.map((key, value) =>
// // //         MapEntry(key, Map<String, String>.from(value)));

// // //     // Toggle the slot:
// // //     if (updatedSlots.containsKey(date)) {
// // //       if (updatedSlots[date]![slot] == "Available") {
// // //         // Deselect: Remove the slot.
// // //         updatedSlots[date]!.remove(slot);
// // //         if (updatedSlots[date]!.isEmpty) {
// // //           updatedSlots.remove(date);
// // //         }
// // //       } else {
// // //         // Mark the slot as available.
// // //         updatedSlots[date]![slot] = "Available";
// // //       }
// // //     } else {
// // //       updatedSlots[date] = {slot: "Available"};
// // //     }

// // //     await _firestore.collection('Tutor_Sessions').doc(userEmail).set({
// // //       'username': username,
// // //       'email': userEmail,
// // //       'student_email': "",
// // //       'availability': updatedSlots,
// // //     }, SetOptions(merge: true));
// // //   }

// // //   /// Generates the list of possible time slots for the given date.
// // //   List<String> generateTimeSlots(String selectedDate) {
// // //     List<String> allSlots = [
// // //       "09:00-10:00",
// // //       "10:00-11:00",
// // //       "11:00-12:00",
// // //       "14:00-15:00",
// // //       "15:00-16:00",
// // //       "16:00-17:00",
// // //       "17:00-18:00",
// // //       "18:00-19:00",
// // //       "19:00-20:00",
// // //     ];

// // //     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// // //     DateTime now = DateTime.now();

// // //     if (selectedDate == today) {
// // //       int currentHour = now.hour;
// // //       return allSlots.where((slot) {
// // //         int slotHour = int.parse(slot.split(':')[0]);
// // //         return slotHour > currentHour;
// // //       }).toList();
// // //     }

// // //     return allSlots;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // While we haven't loaded the tutor's email/username, show a loader.
// // //     if (userEmail.isEmpty) {
// // //       return Scaffold(
// // //         appBar: AppBar(title: Text("Manage Availability")),
// // //         body: Center(child: CircularProgressIndicator()),
// // //       );
// // //     }

// // //     DateTime now = DateTime.now();
// // //     List<String> next7Days = List.generate(7, (index) {
// // //       return DateFormat('yyyy-MM-dd').format(now.add(Duration(days: index)));
// // //     });

// // //     return Scaffold(
// // //       appBar: AppBar(title: Text("Manage Availability")),
// // //       body: StreamBuilder<DocumentSnapshot>(
// // //         stream: _firestore.collection('Tutor_Sessions').doc(userEmail).snapshots(),
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             return Center(child: CircularProgressIndicator());
// // //           }
// // //           if (snapshot.hasError) {
// // //             return Center(child: Text("Error: ${snapshot.error}"));
// // //           }

// // //           // Parse Firestore data into a Map<String, Map<String, String>>
// // //           Map<String, Map<String, String>> currentSlots = {};
// // //           if (snapshot.data != null && snapshot.data!.exists) {
// // //             var data = snapshot.data!.data();
// // //             if (data is Map<String, dynamic> && data.containsKey('availability')) {
// // //               Map<String, dynamic> availabilityData = data['availability'];
// // //               availabilityData.forEach((date, slots) {
// // //                 Map<String, String> parsedSlots = {};
// // //                 (slots as Map<String, dynamic>).forEach((timeSlot, status) {
// // //                   parsedSlots[timeSlot] = status;
// // //                 });
// // //                 currentSlots[date] = parsedSlots;
// // //               });
// // //             }
// // //           }

// // //           return Column(
// // //             children: [
// // //               Padding(
// // //                 padding: EdgeInsets.all(10),
// // //                 child: Text(
// // //                   "Select your available slots for the week:",
// // //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //                 ),
// // //               ),
// // //               Expanded(
// // //                 child: ListView.builder(
// // //                   itemCount: next7Days.length,
// // //                   itemBuilder: (context, index) {
// // //                     String date = next7Days[index];
// // //                     List<String> slotsForDay = generateTimeSlots(date);

// // //                     return Card(
// // //                       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// // //                       child: ExpansionTile(
// // //                         title: Text(
// // //                           "${DateFormat('EEE, MMM d').format(DateTime.parse(date))}",
// // //                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                         ),
// // //                         children: [
// // //                           Wrap(
// // //                             spacing: 10,
// // //                             children: slotsForDay.map((slot) {
// // //                               // Determine the current status for this slot.
// // //                               String status = currentSlots[date]?[slot] ?? "Unavailable";
// // //                               bool isSelected = status == "Available";
// // //                               bool isRequested = status == "Requested";
// // //                               bool isBooked = status == "Booked";

// // //                               Color slotColor = Colors.white;
// // //                               if (isSelected) slotColor = Colors.green;
// // //                               if (isRequested) slotColor = Colors.orange;
// // //                               if (isBooked) slotColor = Colors.purple;

// // //                               return GestureDetector(
// // //                                 onTap: () {
// // //                                   // Allow toggling only if the slot is not requested or booked.
// // //                                   if (!isRequested && !isBooked) {
// // //                                     _updateSlot(date, slot, currentSlots);
// // //                                   }
// // //                                 },
// // //                                 child: Container(
// // //                                   margin: EdgeInsets.all(5),
// // //                                   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// // //                                   decoration: BoxDecoration(
// // //                                     color: slotColor,
// // //                                     borderRadius: BorderRadius.circular(10),
// // //                                     border: Border.all(color: Colors.black, width: 1),
// // //                                   ),
// // //                                   child: Text(
// // //                                     slot,
// // //                                     style: TextStyle(
// // //                                       fontSize: 16,
// // //                                       fontWeight: FontWeight.bold,
// // //                                       color: (isRequested || isBooked) ? Colors.white : Colors.black,
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                               );
// // //                             }).toList(),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }


