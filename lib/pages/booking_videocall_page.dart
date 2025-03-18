import 'package:flutter/material.dart';
import 'package:tutorconnect_app/pages/AvailableTutorsPage.dart';
import 'package:tutorconnect_app/pages/vediocall_page.dart'; // Create this page

class BookingVideoCall extends StatelessWidget {
  final String subCategory;

  const BookingVideoCall({super.key, required this.subCategory});

  void _navigateToPage(BuildContext context, String bookingType) {
    if (bookingType == "In-Person") {
      // Navigate to AvailableTutorsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableTutorsPage(subCategory: subCategory, bookingType: bookingType),
        ),
      );
    } else if (bookingType == "Video Call") {
      // Navigate to a new page for video call subcategories
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallPage(subCategory: subCategory,bookingType: bookingType),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Booking Type"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Select your preferred mode of learning",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBookingOption(
                      context,
                      "In-Person",
                      "assets/images/tutionBokking.png",
                      "Meet your tutor face-to-face.",
                      () => _navigateToPage(context, "In-Person"),
                    ),
                    const SizedBox(width: 12),
                    _buildBookingOption(
                      context,
                      "Video Call",
                      "assets/images/vediocall.jpg",
                      "Learn online with real-time video sessions.",
                      () => _navigateToPage(context, "Video Call"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingOption(
    BuildContext context,
    String title,
    String imagePath,
    String description,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: SizedBox(
            height: 350,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(
                      imagePath,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
