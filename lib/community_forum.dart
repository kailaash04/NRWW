import 'package:flutter/material.dart';
import 'package:nrw/complaint.dart';
import 'package:nrw/main.dart';
import 'package:nrw/manage.dart';
import 'post_model.dart'; 
import 'post_write_page.dart'; 

class CommunityForumPage extends StatefulWidget {
  @override
  _CommunityForumPageState createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage> {
  List<Post> staticPosts = [
    Post(
      'Water is a elixir of our life we should save it and preserve it.',
      imageUrl: 'assets/water conserve.jpg',
    ),
    Post(
      'தண்ணீர் நம் வாழ்வின் அமுதம் அதை நாம் காப்பாற்றி பாதுகாக்க வேண்டும்',
      imageUrl: 'assets/water.jpg',
    ),
    Post(
      'बायोगैस का उत्पादन कार्बनिक पदार्थों के अपघटन से होता है। इसका उपयोग खाना पकाने और बिजली उत्पादन के लिए किया जा सकता है।',
      imageUrl: 'assets/earth.jpg',
    ),
  ];

  List<Post> dynamicPosts = [];

  void _toggleLike(int index) {
    setState(() {
      if (index < dynamicPosts.length) {
        dynamicPosts[index].isLiked = !dynamicPosts[index].isLiked;
      } else {
        int staticIndex = index - dynamicPosts.length;
        staticPosts[staticIndex].isLiked = !staticPosts[staticIndex].isLiked;
      }
    });
  }

  void _addPost(String text, String? imageUrl) {
    setState(() {
      dynamicPosts.insert(0, Post(text, imageUrl: imageUrl));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Post> allPosts = [...dynamicPosts, ...staticPosts];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostWritePage(
                    onPostCreated: _addPost,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rain.jpg'),
            fit: BoxFit.cover,  // Makes the image cover the full height and width
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(255, 123, 121, 121).withOpacity(0.2),
              BlendMode.difference,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: allPosts.isEmpty
            ? const Center(
                child: Text(
                  'No posts yet',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final post = allPosts[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              post.imageUrl!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          post.text,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.createdAt.toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: post.isLiked ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleLike(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment, color: Colors.grey),
                              onPressed: () {
                                // Handle comment action here
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
        selectedItemColor: const Color.fromARGB(255, 17, 114, 218),
        unselectedItemColor: const Color.fromARGB(222, 255, 251, 251),
        currentIndex: 0,
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
    );
  }
}
