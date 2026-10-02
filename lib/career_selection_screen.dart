import 'dart:ui';
import 'package:flutter/material.dart';
import 'chatbot_screen.dart';

class CareerSelectionScreen extends StatelessWidget {
  const CareerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Welcome Back,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Text("Explore Careers", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF3B82F6),
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Centered & Balanced Grid Section
                Expanded(
                  child: Center(
                    child: GridView.builder(
                      shrinkWrap: true, // Forces the grid to only take up necessary space
                      physics: const NeverScrollableScrollPhysics(), // Prevents unnecessary scrolling
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85, // Makes the cards slightly taller for a premium feel
                      ),
                      itemCount: careers.length,
                      itemBuilder: (context, index) {
                        final career = careers[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatbotScreen(selectedCareer: career["title"])),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (career["color"] as Color).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: (career["color"] as Color).withOpacity(0.3), width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(career["icon"], size: 48, color: career["color"]),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Text(
                                        career["title"],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, height: 1.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> careers = [
  {"title": "Computer Engineering", "color": Colors.cyanAccent, "icon": Icons.computer},
  {"title": "Mechanical Engineering", "color": Colors.orangeAccent, "icon": Icons.build},
  {"title": "Civil Engineering", "color": Colors.greenAccent, "icon": Icons.apartment},
  {"title": "Electrical Engineering", "color": Colors.pinkAccent, "icon": Icons.electrical_services},
];