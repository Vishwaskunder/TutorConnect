import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us Page'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/about_us_bg.webp"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? Colors.black.withOpacity(0.6)
                      : Colors.white.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "About Us",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome to TutorConnect",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your premier destination for connecting students with qualified tutors. Our mission is to facilitate personalized learning experiences that empower students to achieve their academic goals.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Section(
                    title: "Our Mission",
                    content:
                        "At TutorConnect, we believe that every student deserves access to quality education. Our platform bridges the gap between learners and educators, fostering an environment where knowledge thrives.",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  Section(
                    title: "What We Offer",
                    content:
                        "- Diverse Tutor Profiles: Explore a wide range of tutor profiles across various subjects.\n"
                        "- Seamless Scheduling: Book sessions effortlessly with our user-friendly system.\n"
                        "- Secure Communication: Communicate directly with tutors through secure messaging.",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  Section(
                    title: "Our Values",
                    content:
                        "- Trust: A safe and reliable learning environment.\n"
                        "- Growth: Continuous learning and development for academic excellence.\n"
                        "- Integrity: Upholding the highest standards in all our offerings.",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Join Us",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Whether you're a student seeking guidance or a tutor looking to share your expertise, TutorConnect is here to support your educational journey. Together, we can achieve excellence.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final String content;
  final bool isDarkMode;

  const Section({super.key, 
    required this.title,
    required this.content,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white60 : Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';

// class AboutUsPage extends StatelessWidget{
//   const AboutUsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      
//       appBar: AppBar(
//         title: Text('AboutUs Page'),
//       ),
//       body: Center(
//         child: Text('AboutUs content goes here'),
//       ),
//     );
//   }

// }