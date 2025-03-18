import 'package:flutter/material.dart';
import 'package:tutorconnect_app/pages/subcategory_page.dart'; // Import the SubCategoryPage

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 16,
                child: Text(
                  'Welcome to TutorConnect',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCategoryCard(context, 'Academics', Icons.school, Colors.purple),
              _buildCategoryCard(context, 'Coding & Technology', Icons.code, Colors.blue),
              _buildCategoryCard(context, 'Competitive Exams', Icons.assignment, Colors.orange),
              _buildCategoryCard(context, 'Sports', Icons.sports_soccer, Colors.green),
              _buildCategoryCard(context, 'Entertainment', Icons.movie, Colors.red),
              _buildCategoryCard(context, 'Languages', Icons.language, Colors.teal),
              _buildCategoryCard(context, 'Yoga', Icons.self_improvement, Colors.amber),
              _buildCategoryCard(context, 'Career Guidance', Icons.work, Colors.deepOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate to the SubCategoryPage and pass the selected category title
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubCategoryPage(category: title),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

