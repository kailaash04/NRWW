import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nrw/community_forum.dart';
import 'package:nrw/complaint.dart';
import 'package:nrw/main.dart';
import 'package:nrw/manage.dart';

class ConfirmationPage extends StatelessWidget {
  final String name;
  final String phone;
  final String city;
  final String problem;
  final File? imageFile;

  ConfirmationPage({
    required this.name,
    required this.phone,
    required this.city,
    required this.problem,
    this.imageFile,
  });

  Future<void> _sendDataToFirestore() async {
    String? imageUrl;

    try {
      if (imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(imageFile!);
        final snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('complaints').add({
        'name': name,
        'phno': phone,
        'location': city,
        'statement': problem,
        'imageUrl': imageUrl, 
        'timestamp': FieldValue.serverTimestamp(),
        'complaintStatus': "Pending"
      });
    } catch (e) {
      print('Error sending data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Confirmation'),
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Name: $name', style: const TextStyle(fontSize: 15)),
              Text('Phone: $phone', style: const TextStyle(fontSize: 15)),
              Text('Location/City: $city', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              const Text(
                'Problem Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(problem, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              const Text(
                'Uploaded Image',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              imageFile != null
                  ? Image.file(imageFile!)
                  : const Text('Image not uploaded', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _sendDataToFirestore();
                  Navigator.pop(context); 
                },
                child: const Text('Send'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text('File Another Complaint'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
        selectedItemColor: const Color.fromARGB(255, 17, 114, 218),
        unselectedItemColor: const Color.fromARGB(222, 255, 251, 251),
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaint',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommunityForumPage()),
            );
            
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManagePage()),
            );
            
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
            
          }else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ComplaintPage()),
            );
          }
        },
      ),
    );
  }
}
