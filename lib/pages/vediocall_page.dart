import 'package:flutter/material.dart';

class VideoCallPage extends StatelessWidget {
  final String subCategory;
  final String bookingType;
  
  const VideoCallPage({super.key, required this.subCategory,required this.bookingType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$subCategory - Video Call"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Select a subcategory for video call under $subCategory.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
