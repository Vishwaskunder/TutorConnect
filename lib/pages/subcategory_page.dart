import 'package:flutter/material.dart';

import 'package:tutorconnect_app/pages/booking_videocall_page.dart'; // Import the BookingVideoCallPage

class SubCategoryPage extends StatelessWidget {
  final String category;

  const SubCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Subcategories for each main category
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

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Subcategories'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: subCategories[category]?.length ?? 0,
        itemBuilder: (context, index) {
          final subCategory = subCategories[category]![index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(subCategory),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to BookingVideoCallPage with the selected subcategory
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>BookingVideoCall (subCategory: subCategory),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

