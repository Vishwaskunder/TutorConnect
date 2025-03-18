import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorconnect_app/components/user_tile.dart';
import 'package:tutorconnect_app/services/auth/auth_service.dart';
import 'package:tutorconnect_app/services/chat/chat_service.dart';
import 'package:tutorconnect_app/pages/ChatPage2.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Get current user
  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildUserList(),
    );
  }

  // Build user list
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if data exists and is not empty
        if (!snapshot.hasData || snapshot.data == null || (snapshot.data as List).isEmpty) {
          return const Center(child: Text("No users available"));
        }

        // If data is available, return list view
        List<dynamic> userList = snapshot.data as List<dynamic>;
        return ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            final userData = userList[index] as Map<String, dynamic>?;

            // Ensure userData is not null before accessing fields
            if (userData == null || !userData.containsKey("email")) {
              return const SizedBox.shrink(); // Avoid errors
            }

            return _buildUserListItem(userData, context);
          },
        );
      },
    );
  }

  // Build individual user item
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    final currentUser = _authService.getCurrentUser();

    // Ensure we don't display the current user in the list
    if (currentUser != null && userData["email"] != currentUser.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage2(
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink(); // Return an empty widget if the user is the same
    }
  }
}

