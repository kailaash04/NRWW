import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nrw/community_forum.dart';
import 'package:nrw/complaint_history.dart';
import 'package:nrw/main.dart';
import 'package:nrw/manage.dart';
import 'confirmation.dart';

class ComplaintPage extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _problemController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('complaint_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> assignEmployeeToComplaint(String complaintId) async {
    try {
      final employeesRef = FirebaseFirestore.instance.collection('employees');
      final availableEmployeesSnapshot = await employeesRef.where('availability', isEqualTo: true).limit(1).get();

      if (availableEmployeesSnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('complaints').doc(complaintId).update({
          'employee_assigned': false,
          'employee_id': "",
        });
        return;
      }

      final employeeDoc = availableEmployeesSnapshot.docs.first;
      final employeeId = employeeDoc.id;

      await FirebaseFirestore.instance.collection('employees').doc(employeeId).update({
        'availability': false,
        'assignedComplaint': complaintId,
      });

      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).update({
        'employee_id': employeeId,
        'employee_assigned': true,
      });
    } catch (e) {
      print('Error assigning employee: $e');
      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).update({
        'employee_assigned': false,
        'employee_id': "",
      });
    }
  }

  Future<void> submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String phone = _phoneController.text;
      String city = _cityController.text;
      String problem = _problemController.text;

      final batch = FirebaseFirestore.instance.batch();
      final complaintRef = FirebaseFirestore.instance.collection('complaints').doc();

      final complaintData = {
        'name': name,
        'phone': phone,
        'location': city,
        'statement': problem,
        'employee_assigned': false,
        'timestamp': FieldValue.serverTimestamp(),
        'image_url': _selectedImage != null ? await uploadImage(_selectedImage!) : null,
        'complaintStatus': "Pending",
      };

      batch.set(complaintRef, complaintData);
      await batch.commit();
      await assignEmployeeToComplaint(complaintRef.id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(
            name: name,
            phone: phone,
            city: city,
            problem: problem,
            imageFile: _selectedImage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File a Complaint'),
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
        actions: [
          IconButton(
            icon: const Icon(Icons.history), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComplaintHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your location/city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Issue', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _problemController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe your problem here...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your problem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Image (Optional)'),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.file(_selectedImage!, height: 150),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitComplaint,
                child: const Text('Submit'),
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
        currentIndex: 3, // Updated current index to match the Complaint tab
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'Management',
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CommunityForumPage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagePage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          } else if (index == 3) {
            // Stay on the current page (ComplaintPage)
          }
        },
      ),
    );
  }
}
