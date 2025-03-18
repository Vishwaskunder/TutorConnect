import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:convert';
// import 'package:crypto/crypto.dart';

import 'package:tutorconnect_app/pages/studentInfoForm_page.dart';
import 'package:tutorconnect_app/pages/tutor_info_form_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminBoard(username: 'Admin'),
    );
  }
}

class AdminBoard extends StatefulWidget {
  final String username;
  const AdminBoard({super.key, required this.username});

  @override
  State<AdminBoard> createState() => _AdminBoardState();
}

class _AdminBoardState extends State<AdminBoard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isMenuOpen = false;
  String selectedMenu = 'Create Tutor';

  final TextEditingController _tutorUsernameController = TextEditingController();
  final TextEditingController _tutorPasswordController = TextEditingController();
  final TextEditingController _tutorEmailController = TextEditingController();
  String? selectedCategory;
  String? selectedSubcategory;

  Map<String, List<String>> categories = {
    'Academics': ['Class 1-7', 'Class 8-9', '10th Science', '10th Maths', '10th Social Science', 'PU Mathematics', 'Physics', 'Chemistry', 'Economics', 'History'],
    'Coding & Technology': ['Python', 'HTML/CSS', 'JavaScript', 'Data Science', 'AI/ML', 'C/C++', 'React', 'React Native', 'Flutter'],
    'Competitive Exams': ['UPSC', 'GRE', 'GMAT', 'SAT'],
    'Sports': ['Football', 'Basketball', 'Tennis', 'Cricket', 'Kabaddi', 'Chess', 'Athletics'],
    'Entertainment': ['Music', 'Dance', 'Acting'],
    'Languages': ['English', 'French', 'Spanish', 'German', 'Hindi'],
    'Yoga': ['Beginner Yoga', 'Power Yoga', 'Meditation', 'Flexibility'],
    'Career Guidance': ['Resume Building', 'Interview Prep'],
  };

  Future<void> createTutorCredential() async {
    final username = _tutorUsernameController.text.trim();
    final password = _tutorPasswordController.text.trim();
    final email = _tutorEmailController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty && selectedSubcategory != null) {
      var existingUser = await _firestore
          .collection('tutor_credential')
          .where('username', isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username already exists! Please choose a different username.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var existingEmail = await _firestore
          .collection('tutor_credential')
          .where('email', isEqualTo: email)
          .get();

      if (existingEmail.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already exists! Please choose a different email.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // var hashedPassword = sha256.convert(utf8.encode(password)).toString();

      await _firestore.collection('tutor_credential').add({
        'email': email,
        'username': username,
        'password': password,
        'category':selectedCategory,
        'subCategory': selectedSubcategory,
      });

      _tutorUsernameController.clear();
      _tutorPasswordController.clear();
      _tutorEmailController.clear();
      setState(() {
        selectedCategory = null;
        selectedSubcategory = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutor created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget getMenuContent() {
    switch (selectedMenu) {
      case 'Create Tutor':
        return createTutorForm();
      case 'View Students':
        return StudentInfoForm();
      case 'View Tutors':
        return TutorInfoForm();
      default:
        return createTutorForm();
    }
  }

  
  Widget createTutorForm() {
  return SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Adjust for keyboard
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Tutor',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _tutorEmailController,
                decoration: InputDecoration(
                  labelText: 'Tutor Email ID',
                  labelStyle: TextStyle(color: Colors.black87),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: TextStyle(color: Colors.black87),
                keyboardType: TextInputType.emailAddress, // For email input
                // Optional validation
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _tutorUsernameController,
                decoration: InputDecoration(
                  labelText: 'Tutor Username',
                  labelStyle: TextStyle(color: Colors.black87),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 12),
              TextField(
                controller: _tutorPasswordController,
                decoration: InputDecoration(
                  labelText: 'Tutor Password',
                  labelStyle: TextStyle(color: Colors.black87),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: Text('Select Category', style: TextStyle(color: Colors.black87)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: categories.keys
                    .map((String category) => DropdownMenuItem(
                          value: category,
                          child: Text(category, style: TextStyle(color: Colors.black87)),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                    selectedSubcategory = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (selectedCategory != null)
                DropdownButtonFormField<String>(
                  value: selectedSubcategory,
                  hint: Text('Select Subcategory', style: TextStyle(color: Colors.black87)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: categories[selectedCategory!]!
                      .map((String subcategory) => DropdownMenuItem(
                            value: subcategory,
                            child: Text(subcategory, style: TextStyle(color: Colors.black87)),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubcategory = newValue;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: createTutorCredential,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('Create Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                isMenuOpen = !isMenuOpen;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(child: getMenuContent()),
          if (isMenuOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  isMenuOpen = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: isMenuOpen ? 0 : -MediaQuery.of(context).size.width * 0.75,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(title: const Text('Create Tutor'), onTap: () => setState(() => selectedMenu = 'Create Tutor')),
                  ListTile(title: const Text('View Students'), onTap: () => setState(() => selectedMenu = 'View Students')),
                  ListTile(title: const Text('View Tutors'), onTap: () => setState(() => selectedMenu = 'View Tutors')),
                  // ListTile(title: const Text('Notify Users'), onTap: () => setState(() => selectedMenu = 'Notify Users')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:convert';
// import 'package:crypto/crypto.dart';

// import 'package:tutorconnect_app/pages/studentInfoForm_page.dart';
// import 'package:tutorconnect_app/pages/tutor_info_form_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Admin Dashboard',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       // home: const AdminBoard(),
//     );
//   }
// }

// class AdminBoard extends StatefulWidget {
//   final String username;
//   const AdminBoard({super.key, required this.username});

//   @override
//   State<AdminBoard> createState() => _AdminBoardState();
// }

// class _AdminBoardState extends State<AdminBoard> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
//   bool isMenuOpen = false;
//   String selectedMenu = 'Create Tutor';

//   final TextEditingController _tutorUsernameController = TextEditingController();
//   final TextEditingController _tutorPasswordController = TextEditingController();
//   final TextEditingController _tutorEmailController= TextEditingController();
//   String? selectedCategory;
//   String? selectedSubcategory;





//   Map<String, List<String>> categories = {
//     'Academics': ['Class 1-7', 'Class 8-9', '10th Science', '10th Maths', '10th Social Science', 'PU Mathematics', 'Physics', 'Chemistry', 'Economics', 'History'],
//     'Coding & Technology': ['Python', 'HTML/CSS', 'JavaScript', 'Data Science', 'AI/ML', 'C/C++', 'React', 'React Native', 'Flutter'],
//     'Competitive Exams': ['UPSC', 'GRE', 'GMAT', 'SAT'],
//     'Sports': ['Football', 'Basketball', 'Tennis', 'Cricket', 'Kabaddi', 'Chess', 'Athletics'],
//     'Entertainment': ['Music', 'Dance', 'Acting'],
//     'Languages': ['English', 'French', 'Spanish', 'German', 'Hindi'],
//     'Yoga': ['Beginner Yoga', 'Power Yoga', 'Meditation', 'Flexibility'],
//     'Career Guidance': ['Resume Building', 'Interview Prep'],
//   };

//   Future<void> createTutorCredential() async {
//   final username = _tutorUsernameController.text.trim();
//   final password = _tutorPasswordController.text.trim();
//   final email= _tutorEmailController.text.trim();

//   if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty && selectedSubcategory != null) {
//     var existingUser = await _firestore
//         .collection('tutor_credential')
//         .where('username', isEqualTo: username)
//         .get();

//     if (existingUser.docs.isNotEmpty) {
//       // Show error message if the username already exists
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Username already exists! Please choose a different username.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return; // Stop further execution
//     }

//     var existingEmail = await _firestore
//         .collection('tutor_credential')
//         .where('email', isEqualTo: email)
//         .get();

//     if (existingEmail.docs.isNotEmpty) {
//       // Show error message if the username already exists
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Email already exists! Please choose a different username.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return; // Stop further execution
//     }
    

//     var hashedPassword = sha256.convert(utf8.encode(password)).toString();

//     await _firestore.collection('tutor_credential').add({
//       'email':email,
//       'username': username,
//       'password': hashedPassword,
//       'profession': selectedSubcategory,
      
//     });

//     // Clear fields after successful registration
//     _tutorUsernameController.clear();
//     _tutorPasswordController.clear();
//     setState(() {
//       selectedCategory = null;
//       selectedSubcategory = null;
//     });

//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Tutor created successfully!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   } else {
//     // Show error if fields are empty
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please fill in all fields.'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }



//   Widget getMenuContent() {
//     switch (selectedMenu) {
//       case 'Create Tutor':
//         return createTutorForm();
//       case 'View Students':
//         return StudentInfoForm();
//       case 'View Tutors':
//         return tutorInfoForm();
    
//       default:
//         return createTutorForm();
//     }
//   }

   

//   Widget createTutorForm() {
//   return SingleChildScrollView(
//     keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//     child: Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Adjust for keyboard
//       child: Card(
//         color: Colors.white,
//         elevation: 8,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Create Tutor',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
//               ),
//               const SizedBox(height: 18),
//               TextFormField(
//                 controller: _tutorEmailController,
//                 decoration: InputDecoration(
//                   labelText: 'Tutor Email ID',
//                   labelStyle: TextStyle(color: Colors.black87),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 style: TextStyle(color: Colors.black87),
//                 keyboardType: TextInputType.emailAddress, // For email input
//                 // Optional validation
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an email address';
//                   } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
//                     return 'Please enter a valid email address';
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _tutorUsernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Tutor Username',
//                   labelStyle: TextStyle(color: Colors.black87),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 style: TextStyle(color: Colors.black87),
//               ),

//               const SizedBox(height: 12),
//               TextField(
//                 controller: _tutorPasswordController,
//                 decoration: InputDecoration(
//                   labelText: 'Tutor Password',
//                   labelStyle: TextStyle(color: Colors.black87),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 obscureText: true,
//                 style: TextStyle(color: Colors.black87),
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: selectedCategory,
//                 hint: Text('Select Category', style: TextStyle(color: Colors.black87)),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 items: categories.keys
//                     .map((String category) => DropdownMenuItem(
//                           value: category,
//                           child: Text(category, style: TextStyle(color: Colors.black87)),
//                         ))
//                     .toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedCategory = newValue;
//                     selectedSubcategory = null;
//                   });
//                 },
//               ),
//               const SizedBox(height: 12),
//               if (selectedCategory != null)
//                 DropdownButtonFormField<String>(
//                   value: selectedSubcategory,
//                   hint: Text('Select Subcategory', style: TextStyle(color: Colors.black87)),
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.grey[200],
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   items: categories[selectedCategory!]!
//                       .map((String subcategory) => DropdownMenuItem(
//                             value: subcategory,
//                             child: Text(subcategory, style: TextStyle(color: Colors.black87)),
//                           ))
//                       .toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedSubcategory = newValue;
//                     });
//                   },
//                 ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: createTutorCredential,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   elevation: 5,
//                 ),
//                 child: const Text('Create Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () {
//               setState(() {
//                 isMenuOpen = !isMenuOpen;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Center(child: getMenuContent()),
//           if (isMenuOpen)
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   isMenuOpen = false;
//                 });
//               },
//               child: Container(
//                 color: Colors.black.withOpacity(0.5),
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//               ),
//             ),
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 300),
//             left: isMenuOpen ? 0 : -MediaQuery.of(context).size.width * 0.75,
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.75,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.white,
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ListTile(title: const Text('Create Tutor'), onTap: () => setState(() => selectedMenu = 'Create Tutor')),
//                   ListTile(title: const Text('View Students'), onTap: () => setState(() => selectedMenu = 'View Students')),
//                   ListTile(title: const Text('View Tutors'), onTap: () => setState(() => selectedMenu = 'View Tutors')),
//                   ListTile(title: const Text('Notify Users'), onTap: () => setState(() => selectedMenu = 'Notify Users')),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


