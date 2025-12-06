import 'package:flutter/material.dart';
import 'package:nrw/community_forum.dart';
import 'package:nrw/complaint.dart';
import 'package:nrw/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'manage.dart';
class Centers extends StatelessWidget {
  const Centers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Contact Centers'),
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {  
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTACT THE INSTALLATION CENTERS!!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 15, 142, 246)),
            ),
            const SizedBox(height: 20),
            _buildContactCenter(
              'murugappawater',
              '"Parry House" 3rd Floor, 43, Moore Street,Chennai - 600 001, India.',
              '+91 44 25306668',
              'solutions@mwts.murugappa.com',
              'https://murugappawater.com/index.html',
            ),
            _buildContactCenter(
              'Asrtal Pipes',
              'Bascon Futura SV IT Park, 2nd Floor(East), 10/1, old no. 56-L, Venkatanarayana Road, Parthasarathi Puram, T. Nagar, Chennai – 600017, India.',
              '+91-44-43506384',
              'chennai@astralpipes.com',
              'https://www.astralpipes.com/?utm_term=underground%20water%20pipe&utm_campaign&utm_source=adwords&utm_medium=ppc&hsa_acc=3432150624&hsa_cam=19714364834&hsa_grp=143102236781&hsa_ad=648724068402&hsa_src=s&hsa_tgt=kwd-301692554&hsa_kw=underground%20water%20pipe&hsa_mt=b&hsa_net=adwords&hsa_ver=3&gad_source=5&gclid=EAIaIQobChMIndDbtYvqhwMVHKZmAh0_VgHEEAAYASAAEgIzivD_BwE',
            ),
            _buildContactCenter(
              'Srbs Sri Ramakrishna Building Services Private Limited',
              'No 1/31, Vedha Nagar Chinmaya Nagar Stage 2, Virugambakkam, Chennai - 600092',
              '9731901031',
              'srbsbuildid@gmail.com',
              'https://www.justdial.com/Chennai/Srbs-Sri-Ramakrishna-Building-Services-Private-Limited-Near-Rto-Office-Virugambakkam/044PXX44-XX44-120121152514-G9N3_BZDET?trkid=&term=&ncatid=11568589&area=&search=Popular%20Water%20Pipe%20Line%20Installation%20Services%20in%20Chennai&mncatname=Water%20Pipe%20Line%20Installation%20Services&abd_btn=Get%20Verified%20Sellers&abd_heading=Water%20Pipe%20Line%20Installation%20Services&bd=1&',
            ),
            _buildContactCenter(
              'Lakshmi Ring Travellers',
              'Sulur Railway Feeder Road,Kurumbapalayam, Muthugoundenpudur,Coimbatore',
              '(0422) 2205000',
              'leedproposal@lrt.co.in',
              'https://www.lrt.co.in/leed/',
            ),
          ],
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
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ComplaintPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildContactCenter(String name, String address, String phone, String email, String website) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(address),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                icon: Icons.phone,
                tooltip: phone,
                onTap: () => _launchUrl('tel:$phone'),
              ),
              _buildIconButton(
                icon: Icons.email,
                tooltip: email,
                onTap: () => _launchUrl('mailto:$email'),
              ),
              _buildIconButton(
                icon: Icons.link,
                onTap: () => _launchUrl(website),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: IconButton(
        icon: Icon(icon, color: const Color.fromARGB(255, 139, 189, 236)),
        onPressed: onTap,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
