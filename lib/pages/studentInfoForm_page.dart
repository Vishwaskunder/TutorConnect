
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentInfoForm extends StatefulWidget {
  const StudentInfoForm({super.key});

  @override
  _StudentInfoFormState createState() => _StudentInfoFormState();
}

class _StudentInfoFormState extends State<StudentInfoForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _students = [];
  DocumentSnapshot? _lastStudentDocument;
  DocumentSnapshot? _firstStudentDocument;
  bool _hasNextPage = true;
  bool _hasPreviousPage = false;
  int _totalStudents = 0;
  final int _studentsPerPage = 20;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTotalStudents();
    _fetchStudents();
  }

  /// Fetch total number of students
  Future<void> _fetchTotalStudents() async {
    try {
      var querySnapshot = await _firestore.collection('tutor_credential').get();
      setState(() {
        _totalStudents = querySnapshot.docs.length;
      });

      // QuerySnapshot querySnapshot = await _firestore
      //     .collection('profiles')
      //     .where('role', isEqualTo: 'Student')
      //     .get();

      // setState(() {
      //   _totalStudents = querySnapshot.docs.length;
      // });
    } catch (e) {
      print("Error fetching total students: $e");
    }
  }

  /// Fetch students with pagination and search
  Future<void> _fetchStudents({bool isNext = true, String? searchQuery}) async {
    // Query query = _firestore
    //     .collection('profiles')
    //     .where('role', isEqualTo: 'Student')
    //     .orderBy('username')
    //     .limit(_studentsPerPage);
    
    Query query = _firestore.collection('student_credential').orderBy('username').limit(_studentsPerPage);

  //  if (searchQuery != null && searchQuery.isNotEmpty) {
  //     query = _firestore
  //         .collection('profiles')
  //         .where('username', isEqualTo: searchQuery)
  //         .limit(1); 
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = _firestore.collection('student_credential')
        .where('username', isEqualTo: searchQuery)
        .limit(1);
    } else if (isNext && _lastStudentDocument != null) {
      query = query.startAfterDocument(_lastStudentDocument!);
    } else if (!isNext && _firstStudentDocument != null) {
      query = query.endBeforeDocument(_firstStudentDocument!).limitToLast(_studentsPerPage);
    }

    try {
      var querySnapshot = await query.get();

      setState(() {
        _students = querySnapshot.docs;
        _firstStudentDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
        _lastStudentDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
        _hasPreviousPage = _firstStudentDocument != null;
        _hasNextPage = querySnapshot.docs.length == _studentsPerPage;
      });
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  void _nextStudentPage() {
    if (_hasNextPage) {
      _fetchStudents(isNext: true);
    }
  }

  void _previousStudentPage() {
    if (_hasPreviousPage) {
      _fetchStudents(isNext: false);
    }
  }

  /// Delete and move student to blocked list
  void _deleteStudent(String studentId, Map<String, dynamic> studentData) async {
    bool? confirmDelete = await _showDeleteConfirmationDialog();

    if (confirmDelete == true) {
      await _firestore.collection('blocked_students').doc(studentId).set(studentData);
      await _firestore.collection('profiles').doc(studentId).delete();
      _fetchStudents();
      _fetchTotalStudents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student has been blocked and removed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Send Notification to Student
  void _sendNotification(String studentId, String message) async {
    try{
        DocumentSnapshot<Map<String,dynamic>> doc =await FirebaseFirestore.instance
            .collection('profiles')
            .doc(studentId)
            .get();

        if (doc.exists){
          String studentEmail =doc.data()?['email']?? '';


            await _firestore.collection('Notifications').add({
              'email':studentEmail,
              'message': message,
              'timestamp': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification sent successfully!'),
                backgroundColor: Colors.blue,
              ),
            );

        }

    }
    catch(e){
         print("Error sending notification: $e");
    }
  }

  /// Show Dialog for Sending Notification
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
    return SingleChildScrollView(
      child: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Username or Email',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _fetchStudents(searchQuery: value),
            ),
          ),


          /// Student List
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                var student = _students[index].data() as Map<String, dynamic>;
                String studentId = _students[index].id;

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blueAccent, width: 1),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(student['username'] ?? 'No Name'),
                    subtitle: Text(student['email'] ?? 'No Email'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.orange),
                          onPressed: () => _showNotifyDialog(context, studentId),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteStudent(studentId, student),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// Pagination Controls
          
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _hasPreviousPage ? _previousStudentPage : null,
                child: Text("Previous"),
              ),
                        /// Total Students Count
              Text(
                'Total Students: $_totalStudents',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
         
              ElevatedButton(
                onPressed: _hasNextPage ? _nextStudentPage : null,
                child: Text("Next"),
              ),
            ],
          ),
        )
          
          
        ],
      ),
    );
  }
}
