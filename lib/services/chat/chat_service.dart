import 'package:firebase_auth/firebase_auth.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorconnect_app/models/messsage.dart';

class ChatService {
  // Get instance of Firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
//   Stream<List<Map<String, dynamic>>> getUsersStream() async* {
//   final user = _auth.currentUser;
//   if (user != null) {
//     final userDoc = await _firestore.collection("Profiles").doc(user.uid).get();
//     if (userDoc.exists) {
//       final role = userDoc.data()?['role'] ?? '';
//       final targetRole = role == 'Student' ? 'Tutor' : 'Student';

//       yield* _firestore
//           .collection("Profiles")
//           .where('role', isEqualTo: targetRole)
//           .snapshots()
//           .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
//     }
//   }
// }


  // // Get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Get each individual user
        final user = doc.data();
        // Return user
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverID, String message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid; // Fixed spelling mistake
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message( // Corrected the instantiation of Message
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the users (sorted to ensure unique)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // Sort the IDs to ensure the chatRoomID is the same for any 2 people
    String chatRoomID = ids.join('_');

    // add new messages to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap()); // Ensure toMap() method exists in Message class
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}


// // class ChatService {
// //   // Get instance of Firestore & auth
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   // Get user stream
// //   Stream<List<Map<String, dynamic>>> getUsersStream() {
// //     return _firestore.collection("Users").snapshots().map((snapshot) {
// //       return snapshot.docs.map((doc) {
// //         // Get each individual user
// //         final user = doc.data() ;
// //         // Return user
// //         return user;
// //       }).toList();
// //     });
// //   }

// //   // send message
// //   Future<void> sendMessage(String receiverID,message) async{
// //     // get current user info
// //     final String currentUserID= _auth.currrent!.uid;
// //     final String currentUserEmail= _auth.currentUser!.email!;
// //     final Timestamp timestamp = Timestamp.now();

// //     // create a new message
// //     Message newMessage = Message{
// //       'senderID': currentUserID,
// //     'senderEmail': currentUserEmail,
// //     'receiverID':receiverID,
// //     'message': message,
// //     'timestamp': timestamp,

// //     };

// //     // construct chat room ID for  the users (sorted to ensure unique)
// //     List<String> ids = [currentUserID, receiverID];
// //     ids.sort();////sort the ids this ensure the chatroomID is the same for any 2 people
// //     String chatRoomID = ids.join('_');


// //     //add new messages to database
// //     await _firestore
// //         .collection("chat_rooms")
// //         .doc(chatRoomID)
// //         .collection("messages")
// //         .add(newMessage.toMap());

// //     }

// //   //get messages
// //   Stream<QuerySnapshot> getMessages(String userID,otherUserID){
// //     List<String> ids = [userID,otherUserID];
// //     ids.sort();
// //     String chatRoomID= ids.join('_');

// //     return _firestore
// //         .collection("chat_rooms")
// //         .doc(chatRoomID)
// //         .collection("messages")
// //         .orderBy("timestamp",descending:false)
// //         .snapshots();
// //   }




// // }
