import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nrw/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'centers.dart';
import 'community_forum.dart';
import 'complaint.dart';

class ManagePage extends StatefulWidget {
  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  String _phValue = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchPhValue();
  }

  Future<void> _fetchPhValue() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('pHValue');
    final DataSnapshot snapshot = await ref.get();
    setState(() {
      _phValue = snapshot.value.toString();
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Page'),
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContainer(
              context,
              title: 'Calculate your water tax\nPay your Bill',
              onViewPressed: () => _launchURL('https://cmwssb.tn.gov.in/index.php/online-water-tax-payment'),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              context,
              title: 'View the installation centers !!',
              onViewPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Centers()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildContainer(
              context,
              title: 'To apply for No objection certificate(NOC) click view',
              onViewPressed: () => _launchURL('https://parivahan.gov.in/parivahan/en/content/no-objection-certificate'),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              context,
              title: 'Get to know about the Green credits',
              onViewPressed: () => _launchURL('https://www.indiawaterportal.org/articles/decoding-green-credit-rules-2023'),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              context,
              title: 'The pH reading is 7.2 the water quality is good.',
              onViewPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 149, 205, 250),
          selectedItemColor: const Color.fromARGB(255, 17, 114, 218),
          unselectedItemColor: const Color.fromARGB(222, 255, 251, 251),
          currentIndex: 1,
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
            
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ComplaintPage()),
            );
          }
        },
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, {required String title, required VoidCallback onViewPressed}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 5, 91, 189).withOpacity(0.3),
            spreadRadius: 4,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onViewPressed,
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }
}
