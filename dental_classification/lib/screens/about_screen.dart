import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About ScanMyTooth"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),

          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                "ScanMyTooth",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "ScanMyTooth is an AI-powered dental diagnosis application that helps patients and dentists analyze dental X-rays efficiently.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Patients can upload dental images, book appointments, receive reports, and communicate with doctors and labs.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Doctors can diagnose cases, manage appointments, and review patient reports using a modern smart workflow.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Our mission is to make dental healthcare smarter, faster, and more accessible using AI technologies.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}