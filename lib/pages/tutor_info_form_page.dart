import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorInfoForm extends StatefulWidget {
  @override
  _TutorInfoFormState createState() => _TutorInfoFormState();
}

class _TutorInfoFormState extends State<TutorInfoForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _tutors = [];
  DocumentSnapshot? _lastDocument;
  DocumentSnapshot? _firstDocument;
  bool _hasNextPage = true;
  bool _hasPreviousPage = false;
  int _totalTutors = 0;
  final int _tutorsPerPage = 20;
  final TextEditingController _searchController = TextEditingController();
   String? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _fetchTotalTutors();
    _fetchTutors();
  }

  Future<void> _fetchTotalTutors() async {
    var querySnapshot = await _firestore.collection('tutor_credential').get();
    setState(() {
      _totalTutors = querySnapshot.docs.length;
    });
  }

  Future<void> _fetchTutors({bool isNext = true, String? searchQuery}) async {
    Query query = _firestore.collection('tutor_credential').orderBy('username').limit(_tutorsPerPage);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = _firestore.collection('tutor_credential')
          .where('username', isEqualTo: searchQuery)
          .limit(1);
    } else if (isNext && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    } else if (!isNext && _firstDocument != null) {
      query = query.endBeforeDocument(_firstDocument!).limitToLast(_tutorsPerPage);
    }

    var querySnapshot = await query.get();
    setState(() {
      _tutors = querySnapshot.docs;
      _firstDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
      _lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
      _hasPreviousPage = _firstDocument != null;
      _hasNextPage = querySnapshot.docs.length == _tutorsPerPage;
    });
  }

  void _nextPage() {
    if (_hasNextPage) {
      _fetchTutors(isNext: true);
    }
  }

  void _previousPage() {
    if (_hasPreviousPage) {
      _fetchTutors(isNext: false);
    }
  }

  Future<void> _deleteTutor(String tutorId, Map<String, dynamic> tutorData) async {
    bool? confirmDelete = await _showDeleteConfirmationDialog();

    if (confirmDelete == true) {
      await _firestore.collection('blocked_tutor').doc(tutorId).set(tutorData);
      await _firestore.collection('tutor_credential').doc(tutorId).delete();
      _fetchTutors();
      _fetchTotalTutors();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tutor has been blocked and removed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this tutor?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _sendNotification(String tutorId, String message) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('tutor_credential')
          .doc(tutorId)
          .get();

      if (doc.exists) {
        String tutorEmail = doc.data()?['email'] ?? '';

        await _firestore.collection('Notifications').add({
          'email': tutorEmail,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tutor not found!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

void _showNotifyDialog(BuildContext context, String studentId) {
    TextEditingController notifyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Send Notification"),
          content: TextField(
            controller: notifyController,
            decoration: InputDecoration(hintText: "Enter message"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _sendNotification(studentId, notifyController.text);
                Navigator.pop(context);
              },
              child: Text("Send", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Tutor Management"),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => _fetchTutors(searchQuery: value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tutors.length,
              itemBuilder: (context, index) {
                var tutor = _tutors[index].data() as Map<String, dynamic>;
                String tutorId = _tutors[index].id;

                return ListTile(
                  title: Text(tutor['username'] ?? 'No Name'),
                  subtitle: Text(tutor['email'] ?? 'No Email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: () => _showNotifyDialog(context,tutorId),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTutor(tutorId, tutor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _hasPreviousPage ? _previousPage : null,
                child: Text("Previous"),
              ),
              Text("Total Tutors: $_totalTutors"),
              ElevatedButton(
                onPressed: _hasNextPage ? _nextPage : null,
                child: Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

