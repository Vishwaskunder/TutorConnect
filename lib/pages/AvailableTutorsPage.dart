import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailableTutorsPage extends StatefulWidget {
  final String subCategory;
  final String bookingType;

  const AvailableTutorsPage({super.key, required this.subCategory, required this.bookingType});

  @override
  _AvailableTutorsPageState createState() => _AvailableTutorsPageState();
}

class _AvailableTutorsPageState extends State<AvailableTutorsPage> {
  String? selectedTutorEmail;
  Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

  Future<List<Map<String, dynamic>>> _fetchTutors() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('tutor_credential')
        .where('subCategory', isEqualTo: widget.subCategory)
        .get();

    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> _fetchAvailability(String tutorEmail) async {
    final doc = await FirebaseFirestore.instance.collection('Tutor_Sessions').doc(tutorEmail).get();

    if (doc.exists && doc.data()?['availability'] != null) {
      Map<String, dynamic> fetchedData = doc.data()?['availability'];
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
  }


  void _toggleTutorDetails(String tutorEmail) {
    setState(() {
      if (selectedTutorEmail == tutorEmail) {
        selectedTutorEmail = null;
      } else {
        selectedTutorEmail = tutorEmail;
        if (!tutorAvailability.containsKey(tutorEmail)) {
          _fetchAvailability(tutorEmail);
        }
      }
    });
  }

  void _showBookingPopup(String tutorEmail, String date, String slot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Booking"),
          content: Text(
              "Are you booking the slot? You will receive a confirmation notification later from tutor ($tutorEmail). If not, please message your tutor."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => _bookSlot(tutorEmail, date, slot),
              child: Text("Book"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _bookSlot(String tutorEmail, String date, String slot) async {
    String? studentEmail = FirebaseAuth.instance.currentUser?.email;
    if (studentEmail == null) return;

    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await FirebaseFirestore.instance.collection('Notifications').add({
      'email': studentEmail,
      'message': "Your booking request has been sent for slot $slot on $date to the Tutor $tutorEmail ",
      'timestamp': formattedTimestamp,
    });

    await FirebaseFirestore.instance.collection('Notifications').add({
      'email': tutorEmail,
      'message': "You get request for the $slot on $date from $studentEmail. Acept  it faster",
      'timestamp': formattedTimestamp,
    });

    await FirebaseFirestore.instance.collection('Booking_info').add({
      'Student_Email':studentEmail,
      'Tutor_Email':tutorEmail,
      'status':'Panding',
      'amount':'300',
      'timestamp': formattedTimestamp,
      'timeslot':date+' '+slot
    });

    await FirebaseFirestore.instance.collection('Tutor_Sessions').doc(tutorEmail).update({
      'availability.$date.$slot': "Requested",
    });

    setState(() {
      tutorAvailability[tutorEmail]?[date]?[slot] = "Requested";
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Tutors"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTutors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No tutors available for this subcategory."));
          }

          List<Map<String, dynamic>> tutors = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              var tutor = tutors[index];
              bool isExpanded = selectedTutorEmail == tutor['email'];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(tutor['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Email: ${tutor['email']}"),
                      trailing: ElevatedButton(
                        onPressed: () => _toggleTutorDetails(tutor['email']),
                        child: Text(isExpanded ? "Hide Slots" : "View Slots"),
                      ),
                    ),
                    if (isExpanded && tutorAvailability.containsKey(tutor['email']))
                      _buildAvailabilitySection(tutor['email']),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvailabilitySection(String tutorEmail) {
    var availability = tutorAvailability[tutorEmail] ?? {};

    return availability.isEmpty
        ? Padding(
            padding: EdgeInsets.all(10),
            child: Center(child: CircularProgressIndicator()),
          )
        : Column(
            children: availability.keys.map((date) {
              String formattedDate = _formatDateWithDay(date);
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  title: Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Wrap(
                      spacing: 10,
                      children: availability[date]!.keys.map((slot) {
                        String status = availability[date]?[slot] ?? "Unavailable";
                        bool isAvailable = status == "Available";

                        return GestureDetector(
                          onTap: isAvailable ? () => _showBookingPopup(tutorEmail, date, slot) : null,
                          child: Container(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
  }

  String _formatDateWithDay(String date) {
    try {
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      String dayOfWeek = DateFormat('EEEE').format(parsedDate);
      return "$date ($dayOfWeek)";
    } catch (e) {
      return date;
    }
  }
}




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class AvailableTutorsPage extends StatefulWidget {
//   final String subCategory;
//   final String bookingType;

//   const AvailableTutorsPage({super.key, required this.subCategory, required this.bookingType});

//   @override
//   _AvailableTutorsPageState createState() => _AvailableTutorsPageState();
// }

// class _AvailableTutorsPageState extends State<AvailableTutorsPage> {
//   String? selectedTutorEmail;
//   Map<String, Map<String, Map<String, String>>> tutorAvailability = {};

//   Future<List<Map<String, dynamic>>> _fetchTutors() async {
//     QuerySnapshot query = await FirebaseFirestore.instance
//         .collection('tutor_credential')
//         .where('subCategory', isEqualTo: widget.subCategory)
//         .get();

//     return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//   }

//   Future<void> _fetchAvailability(String tutorEmail) async {
//     final doc = await FirebaseFirestore.instance.collection('Tutor_Sessions').doc(tutorEmail).get();

//     if (doc.exists && doc.data()?['availability'] != null) {
//       Map<String, dynamic> fetchedData = doc.data()?['availability'];
//       Map<String, Map<String, String>> formattedData = {};

//       fetchedData.forEach((date, slots) {
//         Map<String, String> parsedSlots = {};
//         (slots as Map<String, dynamic>).forEach((timeSlot, status) {
//           parsedSlots[timeSlot] = status;
//         });
//         formattedData[date] = parsedSlots;
//       });

//       setState(() {
//         tutorAvailability[tutorEmail] = formattedData;
//       });
//     }
//   }

//   void _toggleTutorDetails(String tutorEmail) {
//     setState(() {
//       if (selectedTutorEmail == tutorEmail) {
//         selectedTutorEmail = null;
//       } else {
//         selectedTutorEmail = tutorEmail;
//         if (!tutorAvailability.containsKey(tutorEmail)) {
//           _fetchAvailability(tutorEmail);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Available Tutors"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchTutors(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text("No tutors available for this subcategory."));
//           }

//           List<Map<String, dynamic>> tutors = snapshot.data!;

//           return ListView.builder(
//             padding: EdgeInsets.all(10),
//             itemCount: tutors.length,
//             itemBuilder: (context, index) {
//               var tutor = tutors[index];
//               bool isExpanded = selectedTutorEmail == tutor['email'];

//               return Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 elevation: 3,
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.blueAccent,
//                         child: Icon(Icons.person, color: Colors.white),
//                       ),
//                       title: Text(tutor['username'], style: TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Text("Email: ${tutor['email']}"),
//                       trailing: ElevatedButton(
//                         onPressed: () => _toggleTutorDetails(tutor['email']),
//                         child: Text(isExpanded ? "Hide Slots" : "View Slots"),
//                       ),
//                     ),
//                     if (isExpanded && tutorAvailability.containsKey(tutor['email']))
//                       _buildAvailabilitySection(tutor['email']),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAvailabilitySection(String tutorEmail) {
//     var availability = tutorAvailability[tutorEmail] ?? {};

//     return availability.isEmpty
//         ? Padding(
//             padding: EdgeInsets.all(10),
//             child: Center(child: CircularProgressIndicator()),
//           )
//         : Column(
//             children: availability.keys.map((date) {
//               String formattedDate = _formatDateWithDay(date);
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 child: ExpansionTile(
//                   title: Text(
//                     formattedDate,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   children: [
//                     Wrap(
//                       spacing: 10,
//                       children: availability[date]!.keys.map((slot) {
//                         String status = availability[date]?[slot] ?? "Unavailable";
//                         bool isAvailable = status == "Available";

//                         return GestureDetector(
//                           onTap: isAvailable ? () => print("Booked $slot on $date") : null,
//                           child: Container(
//                             margin: EdgeInsets.all(5),
//                             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                             decoration: BoxDecoration(
//                               color: isAvailable ? Colors.green : Colors.grey,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.black, width: 1),
//                             ),
//                             child: Text(
//                               slot,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: isAvailable ? Colors.white : Colors.black,
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           );
//   }

//   String _formatDateWithDay(String date) {
//     try {
//       DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
//       String dayOfWeek = DateFormat('EEEE').format(parsedDate);
//       return "$date ($dayOfWeek)";
//     } catch (e) {
//       return date;
//     }
//   }
// }




// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class AvailableTutorsPage extends StatelessWidget {
// //   final String subCategory;
// //   final String bookingType;

// //   const AvailableTutorsPage({super.key, required this.subCategory, required this.bookingType});

// //   Future<List<Map<String, dynamic>>> _fetchTutors() async {
// //     QuerySnapshot query = await FirebaseFirestore.instance
// //         .collection('tutor_credential')
// //         .where('subCategory', isEqualTo: subCategory)
// //         .get();

// //     return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Available Tutors"),
// //         backgroundColor: Colors.blueAccent,
// //       ),
// //       body: FutureBuilder<List<Map<String, dynamic>>>(
// //         future: _fetchTutors(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           }
// //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //             return Center(child: Text("No tutors available for this subcategory."));
// //           }

// //           List<Map<String, dynamic>> tutors = snapshot.data!;

// //           return ListView.builder(
// //             padding: EdgeInsets.all(10),
// //             itemCount: tutors.length,
// //             itemBuilder: (context, index) {
// //               var tutor = tutors[index];
// //               return Card(
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                 elevation: 3,
// //                 child: ListTile(
// //                   leading: CircleAvatar(
// //                     backgroundColor: Colors.blueAccent,
// //                     child: Icon(Icons.person, color: Colors.white),
// //                   ),
// //                   title: Text(tutor['username'], style: TextStyle(fontWeight: FontWeight.bold)),
// //                   subtitle: Text("Email: ${tutor['email']}"),
// //                   trailing: ElevatedButton(
// //                     onPressed: () {
// //                       // Navigate to booking process
// //                     },
// //                     child: Text("Book"),
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
