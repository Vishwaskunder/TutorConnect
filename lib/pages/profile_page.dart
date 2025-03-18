
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorconnect_app/services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _selectedRole = 'Student';
  String _selectedGender = 'Male';
  bool _isEditable = false;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String _errorMessage = '';
  String _usernameError = '';
  String _mobileError = '';
  String _pincodeError = '';

  final Map<String, List<String>> subCategories = {
      'Academics': ['Class 1-7', 'Class 8-9', '10th Science', '10th Maths', '10th Social Science', 'PU Mathematics', 'Physics', 'Chemistry', 'Economics', 'History'],
      'Coding & Technology': ['Python', 'HTML/CSS', 'JavaScript', 'Data Science', 'AI/ML', 'C/C++', 'React', 'React Native', 'Flutter'],
      'Competitive Exams': ['UPSC', 'GRE', 'GMAT', 'SAT'],
      'Sports': ['Football', 'Basketball', 'Tennis', 'Cricket', 'Kabaddi', 'Chess', 'Athletics'],
      'Entertainment': ['Music', 'Dance', 'Acting'],
      'Languages': ['English', 'French', 'Spanish', 'German', 'Hindi'],
      'Yoga': ['Beginner Yoga', 'Power Yoga', 'Meditation', 'Flexibility'],
      'Career Guidance': ['Resume Building', 'Interview Prep'],
  };

  Future<void> _checkTutorCredential() async {
    final tutorRef = FirebaseFirestore.instance.collection('tutor_credential');
    final querySnapshot = await tutorRef
        .where('username', isEqualTo: _usernameController.text)
        // .where('email', isEqualTo: _emailController.text)
        // .where('category',isEqualTo: _selectedCategory)
        .where('subCategory', isEqualTo: _selectedSubCategory)
        .get();

    if (querySnapshot.docs.isEmpty) {

      setState(() {
        _errorMessage = 'Your username, email, and profession do not match. Please request a username from the Tutor app administrator (vishwaskunder1@gmail.com).';
        
      });
    }
  }
    
 
  // Load profile and user details
  Future<void> _loadProfile() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          setState(() {
            _emailController.text = user.email ?? '';
          });
        }

        final userId = user?.uid ?? 'user123';
        final profile = await FirebaseService.loadProfile(userId);

        setState(() {
          _usernameController.text = profile['username'] ?? '';
          _dobController.text = profile['dob'] ?? '';
          _addressController.text = profile['address'] ?? '';
          _nationController.text = profile['nation'] ?? '';
          _stateController.text = profile['state'] ?? '';
          _districtController.text = profile['district'] ?? '';
          _pincodeController.text = profile['pincode'] ?? '';
          _locationController.text = profile['location'] ?? '';
          _mobileController.text = profile['mobile'] ?? '';
          _selectedRole = profile['role'] ?? 'Student';
          _selectedGender = profile['gender'] ?? 'Male';
          // Validate Category
          String? category = profile['category'];
          _selectedCategory = (category != null && subCategories.containsKey(category)) ? category : null;

          // Validate Subcategory
          String? subCategory = profile['subCategory'];
          if (_selectedCategory != null && subCategories[_selectedCategory]!.contains(subCategory)) {
            _selectedSubCategory = subCategory;
          }
          else{
            _selectedCategory=null;
          }
        //   _selectedCategory = profile['category'] ?? ''; // Add this line
        // _selectedSubCategory = profile['subCategory'] ?? ''; // Add this line
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }

    Future<void> _saveProfile() async {
    if (_usernameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _nationController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _selectedCategory == null || _selectedCategory!.isEmpty || 
        _selectedSubCategory == null || _selectedSubCategory!.isEmpty
    ) {
      setState(() {
        _errorMessage = 'Please fill in all the fields.';
      });
      return;
    }

    if (_usernameError.isNotEmpty || _mobileError.isNotEmpty || _pincodeError.isNotEmpty) {
      setState(() {
        _errorMessage = 'Please fix the errors before saving.';
      });
      return;
    }

    if (_selectedRole == 'Tutor') {
      await _checkTutorCredential();
      if (_errorMessage.isNotEmpty) return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'user123';
    final profileCollection = FirebaseFirestore.instance.collection('profiles');

    final profileData = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'role': _selectedRole,
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
      'dob': _dobController.text,
      'gender': _selectedGender,
      'address': _addressController.text,
      'nation': _nationController.text,
      'state': _stateController.text,
      'district': _districtController.text,
      'pincode': _pincodeController.text,
      'location': _locationController.text,
      'mobile': _mobileController.text,
    };

    // Save full profile in 'profiles' collection
    final docRef = await profileCollection.doc(userId).get();
    if (docRef.exists) {
      await profileCollection.doc(userId).update(profileData);
    } else {
      await profileCollection.doc(userId).set(profileData);
    }

    // If the user is a student, save limited data in 'student_credential'
    if (_selectedRole == 'Student') {
      final studentCollection = FirebaseFirestore.instance.collection('student_credential');
      final studentDocRef = await studentCollection.doc(userId).get();

      final studentData = {
        'username': _usernameController.text,
        'category': _selectedCategory,
        'subCategory': _selectedSubCategory,
      };

      if (studentDocRef.exists) {
        await studentCollection.doc(userId).update(studentData);
      } else {
        await studentCollection.doc(userId).set({
          ...studentData,
          'email': _emailController.text, // Ensure email is only set on creation
        });
      }
    }

    setState(() {
      _isEditable = false;
      _errorMessage = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
  }



  void _validateUsername(String value) {
  setState(() {
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      _usernameError = 'Enter a valid name (letters and spaces only)';
    } else {
      _usernameError = '';
    }
  });
  }

  void _validateMobile(String value) {
  setState(() {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      _mobileError = 'Mobile number cannot contain letters or special characters';
    } else if (value.length < 10) {
      _mobileError = 'Mobile number must have at least 10 digits';
    } else {
      _mobileError = '';
    }
  });
}


  // Validate pincode: Should only contain numbers
  void _validatePincode(String value) {
    setState(() {
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _pincodeError = 'Pincode should only contain numbers';
      } else {
        _pincodeError = '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDarkMode ? Colors.white : Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextFormField('Username', _usernameController, _validateUsername, errorText: _usernameError),
            _buildReadOnlyField('Email ID', _emailController),
            _buildDropdownField('Role', ['Student', 'Tutor'], _selectedRole, (value) {
              setState(() => _selectedRole = value!);
            }),
            _buildDropdownField('Category', subCategories.keys.toList(), _selectedCategory ?? '', (value) {
              setState(() {
                _selectedCategory = value;
                _selectedSubCategory = null; // Reset subcategory when category changes
              });
            }),
            if (_selectedCategory != null)
            _buildDropdownField('Subcategory', subCategories[_selectedCategory!]!, _selectedSubCategory ?? '', (value) {
              setState(() => _selectedSubCategory = value);
            }),


            _buildDatePickerField('Date of Birth', _dobController),
            _buildDropdownField('Gender', ['Male', 'Female', 'Other'], _selectedGender, (value) {
              setState(() => _selectedGender = value!);
            }),
            _buildPhoneNumberField('Mobile No', _mobileController, _validateMobile, errorText: _mobileError),
            _buildTextFormField('Address', _addressController, (_) => {}),
            _buildTextFormField('Nation', _nationController, (_) => {}),
            _buildTextFormField('State', _stateController, (_) => {}),
            _buildTextFormField('District', _districtController, (_) => {}),
            _buildTextFormField('Pincode', _pincodeController, _validatePincode, keyboardType: TextInputType.number, errorText: _pincodeError),
            _buildTextFormField('Current Location', _locationController, (_) => {}),

         
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            _isEditable
                ? ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.teal : Colors.blue),
                    child: const Text('Save Profile'),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditable = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.teal : Colors.blue),
                    child: const Text('Edit Profile'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, Function? onChanged, {String? errorText, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        onChanged: (value) => onChanged?.call(value),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          fillColor: Colors.grey[300],
          filled: true,
        ),
      ),
    );
  }


  Widget _buildDropdownField(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: DropdownButtonFormField<String>(
      value: items.contains(selectedValue) ? selectedValue : null, // Ensure selected value exists in items
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}


  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toLocal().toString().split(' ')[0];
            });
          }
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(String label, TextEditingController controller, Function? onChanged, {String? errorText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        onChanged: (value) => onChanged?.call(value),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tutorconnect_app/services/profile_service.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _nationController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _districtController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();

//   String _selectedRole = 'Student';
//   String _selectedGender = 'Male';
//   bool _isEditable = false;
//   String _errorMessage = '';
//   String _usernameError = '';
//   String _mobileError = '';
//   String _pincodeError = '';

//   // Load profile and user details
//   Future<void> _loadProfile() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         setState(() {
//           _emailController.text = user.email ?? '';
//         });
//       }

//       final userId = user?.uid ?? 'user123';
//       final profile = await FirebaseService.loadProfile(userId);

//       setState(() {
//         _usernameController.text = profile['username'] ?? '';
//         _dobController.text = profile['dob'] ?? '';
//         _addressController.text = profile['address'] ?? '';
//         _nationController.text = profile['nation'] ?? '';
//         _stateController.text = profile['state'] ?? '';
//         _districtController.text = profile['district'] ?? '';
//         _pincodeController.text = profile['pincode'] ?? '';
//         _locationController.text = profile['location'] ?? '';
//         _mobileController.text = profile['mobile'] ?? '';
//         _selectedRole = profile['role'] ?? 'Student';
//         _selectedGender = profile['gender'] ?? 'Male';
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
//     }
//   }

//   // Save profile data to Firestore
//   Future<void> _saveProfile() async {
//     if (_usernameController.text.isEmpty ||
//         _dobController.text.isEmpty ||
//         _addressController.text.isEmpty ||
//         _nationController.text.isEmpty ||
//         _stateController.text.isEmpty ||
//         _districtController.text.isEmpty ||
//         _pincodeController.text.isEmpty ||
//         _locationController.text.isEmpty ||
//         _mobileController.text.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please fill in all the fields.';
//       });
//       return;
//     }

//     if (_usernameError.isNotEmpty || _mobileError.isNotEmpty || _pincodeError.isNotEmpty) {
//       setState(() {
//         _errorMessage = 'Please fix the errors before saving.';
//       });
//       return;
//     }

//     final profileData = {
//       'username': _usernameController.text,
//       'email': _emailController.text,
//       'role': _selectedRole,
//       'dob': _dobController.text,
//       'gender': _selectedGender,
//       'address': _addressController.text,
//       'nation': _nationController.text,
//       'state': _stateController.text,
//       'district': _districtController.text,
//       'pincode': _pincodeController.text,
//       'location': _locationController.text,
//       'mobile': _mobileController.text,
//     };

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       final userId = user?.uid ?? 'user123';
//       await FirebaseService.saveProfile(userId, profileData);
//       setState(() {
//         _isEditable = false;
//         _errorMessage = '';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
//     }
//   }

//   // Validate username: Only letters
//   void _validateUsername(String value) {
//   setState(() {
//     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
//       _usernameError = 'Enter a valid name (letters and spaces only)';
//     } else {
//       _usernameError = '';
//     }
//   });
// }

//   void _validateMobile(String value) {
//   setState(() {
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       _mobileError = 'Mobile number cannot contain letters or special characters';
//     } else if (value.length < 10) {
//       _mobileError = 'Mobile number must have at least 10 digits';
//     } else {
//       _mobileError = '';
//     }
//   });
// }


//   // Validate pincode: Should only contain numbers
//   void _validatePincode(String value) {
//     setState(() {
//       if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//         _pincodeError = 'Pincode should only contain numbers';
//       } else {
//         _pincodeError = '';
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: isDarkMode ? Colors.white : Colors.blue,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildTextFormField('Username', _usernameController, _validateUsername, errorText: _usernameError),
//             _buildReadOnlyField('Email ID', _emailController),
//             _buildDropdownField('Role', ['Student', 'Tutor'], _selectedRole, (value) {
//               setState(() => _selectedRole = value!);
//             }),
//             _buildDatePickerField('Date of Birth', _dobController),
//             _buildDropdownField('Gender', ['Male', 'Female', 'Other'], _selectedGender, (value) {
//               setState(() => _selectedGender = value!);
//             }),
//             _buildPhoneNumberField('Mobile No', _mobileController, _validateMobile, errorText: _mobileError),
//             _buildTextFormField('Address', _addressController, (_) => {}),
//             _buildTextFormField('Nation', _nationController, (_) => {}),
//             _buildTextFormField('State', _stateController, (_) => {}),
//             _buildTextFormField('District', _districtController, (_) => {}),
//             _buildTextFormField('Pincode', _pincodeController, _validatePincode, keyboardType: TextInputType.number, errorText: _pincodeError),
//             _buildTextFormField('Current Location', _locationController, (_) => {}),

         
//             if (_errorMessage.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: Text(
//                   _errorMessage,
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             const SizedBox(height: 20),
//             _isEditable
//                 ? ElevatedButton(
//                     onPressed: _saveProfile,
//                     style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.teal : Colors.blue),
//                     child: const Text('Save Profile'),
//                   )
//                 : ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isEditable = true;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.teal : Colors.blue),
//                     child: const Text('Edit Profile'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextFormField(String label, TextEditingController controller, Function? onChanged, {String? errorText, TextInputType keyboardType = TextInputType.text}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         onChanged: (value) => onChanged?.call(value),
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: label,
//           errorText: errorText,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Widget _buildReadOnlyField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         readOnly: true,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           fillColor: Colors.grey[300],
//           filled: true,
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownField(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: DropdownButtonFormField<String>(
//         value: selectedValue,
//         onChanged: onChanged,
//         items: items.map((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDatePickerField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         readOnly: true,
//         onTap: () async {
//           DateTime? pickedDate = await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: DateTime(1900),
//             lastDate: DateTime(2100),
//           );
//           if (pickedDate != null) {
//             setState(() {
//               controller.text = pickedDate.toLocal().toString().split(' ')[0];
//             });
//           }
//         },
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Widget _buildPhoneNumberField(String label, TextEditingController controller, Function? onChanged, {String? errorText}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         onChanged: (value) => onChanged?.call(value),
//         keyboardType: TextInputType.phone,
//         decoration: InputDecoration(
//           labelText: label,
//           errorText: errorText,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }
