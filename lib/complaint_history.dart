import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintHistoryPage extends StatefulWidget {
  @override
  _ComplaintHistoryPageState createState() => _ComplaintHistoryPageState();
}

class _ComplaintHistoryPageState extends State<ComplaintHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteComplaint(String id) async {
    try {
      await _firestore.collection('complaints').doc(id).delete();
    } catch (e) {
      print('Error deleting complaint: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('complaints').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return Center(child: Text('No complaints found'));
          }

          final complaints = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index].data() as Map<String, dynamic>;
              final id = complaints[index].id;
              final statement = complaint['statement']?.toString() ?? 'No statement';
              final timestamp = complaint['timestamp'] is Timestamp
                  ? (complaint['timestamp'] as Timestamp).toDate()
                  : null; 
              final imageUrl = complaint['image_url']?.toString() ?? '';
              final status = complaint['complaintStatus']?.toString() ?? 'No status';

              return Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complaint ID: $id', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Statement: $statement', style: TextStyle(fontSize: 16)),
                    Text('Timestamp: ${timestamp != null ? timestamp.toLocal() : "No timestamp"}', style: TextStyle(fontSize: 14)),
                    if (imageUrl.isNotEmpty)
                      Image.network(imageUrl, height: 150, fit: BoxFit.cover),
                    Text('Status: $status', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await _deleteComplaint(id);
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
