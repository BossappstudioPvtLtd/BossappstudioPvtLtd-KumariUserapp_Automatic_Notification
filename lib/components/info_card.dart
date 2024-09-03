import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_app/components/text_add.dart';

class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.name,
    // ignore: non_constant_identifier_names
    required this.Profession,
  });
  // ignore: non_constant_identifier_names
  final String name, Profession;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> with SingleTickerProviderStateMixin {
  User? currentUser = FirebaseAuth.instance.currentUser;
  DatabaseReference? userRef;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      userRef = FirebaseDatabase.instance.reference().child('users/${currentUser!.uid}');
    }

    // Initialize the animation controller and the fade animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return currentUser == null || userRef == null
        ? const Center(child: Text('No user logged in'))
        : StreamBuilder(
            stream: userRef!.onValue,
            builder: (context, AsyncSnapshot event) {
              if (event.hasError) {
                return const Center(
                  child: Text(
                    'An error occurred while fetching data. Please try again later.',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (!event.hasData || event.data.snapshot.value == null) {
                return const Center(
                  child: Icon(Icons.person),
                );
              } else {
                Map data = event.data.snapshot.value;
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25, left: 20),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              _showFullScreenImage(context, data['photo']);
                            },
                            child: Hero(
                              tag: 'profileImage',
                              child: Material(
                                elevation: 20,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl: "${data['photo']}",
                                    width: 57,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: TextEdt(
                          text: ' ${data['name']}',
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: 270,
          
                                width: double.infinity,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
