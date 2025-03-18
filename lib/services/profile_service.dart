import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load profile data from Firestore
  static Future<Map<String, dynamic>> loadProfile(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('profiles').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception("Profile not found");
    }
  }

  // Save profile data to Firestore
  static Future<void> saveProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      await _firestore.collection('profiles').doc(userId).set(profileData);
    } catch (e) {
      throw Exception('Error saving profile: $e');
    }
  }
}

