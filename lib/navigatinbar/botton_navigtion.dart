import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:new_app/comen/common_methords.dart';
import 'package:new_app/navigatinbar/image_animation.dart';
import 'package:new_app/navigatinbar/trips_history_page.dart';
import 'package:new_app/navigatinbar/favorite_page.dart';
import 'package:new_app/navigatinbar/profile_page.dart';
import 'package:new_app/new_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class BottonNavigations extends StatefulWidget {
  const BottonNavigations({super.key});

  @override
  State<BottonNavigations> createState() => _BottonNavigationsState();
}

CommonMethods cMethods = CommonMethods();

const String phoneNumber = "+919994440638"; // Replace with the desired phone number
const String message = "Hello! Welcome to Kumari Cabs support. How can I assist you today? Whether you need help navigating the app, troubleshooting an issue, or have any questions, I'm here to support you. ."; // Replace with the desired message

Future<void> _sendWhatsAppMessage(BuildContext context) async {
  const link = WhatsAppUnilink(
    phoneNumber: phoneNumber,
    text: message,
  );

  if (!await launch('$link')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch WhatsApp')),
    );
  }
}

class _BottonNavigationsState extends State<BottonNavigations> with SingleTickerProviderStateMixin {
  List<IconData> iconList = [
    Icons.home_outlined,
    Icons.account_tree,
    Icons.favorite_outline_sharp,
    Icons.person_2_outlined
  ];
  List<Widget> bottomPages = [
    const HomePage1(),
    const TripsHistoryPage(),
    PageListGuideAr(),
    const ProfilePage()
  ];

  int bottomNavInde = 0;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  
  int flipCount = 0; // To keep track of the number of flips
  bool isPaused = false; // To manage the pause state
  late Timer _pauseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Duration for one flip
    );

    _rotationAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation1 = ColorTween(begin: Colors.amber, end: Colors.tealAccent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _colorAnimation2 = ColorTween(begin: Colors.tealAccent, end: Colors.amber).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addListener(() {
      if (_controller.isCompleted) {
        flipCount++;
        if (flipCount >= 3) {
          if (!isPaused) {
            _pauseTimer = Timer(const Duration(seconds: 5), () {
              setState(() {
                flipCount = 0; // Reset flip count
                _controller.repeat(reverse: true); // Restart the animation
                isPaused = false;
              });
            });
            _controller.stop(); // Stop the animation
            isPaused = true;
          }
        }
      }
    });

    _controller.repeat(reverse: true); // Repeat the animation back and forth
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_pauseTimer.isActive) _pauseTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendWhatsAppMessage(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 22, 60),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final rotation = 2 * 3.14159 * progress; // Full rotation (360 degrees)

            return Transform(
              transform: Matrix4.identity()
                ..rotateY(rotation)
                ..scale(1 + progress * 0.2), // Scale effect for added visual interest
              alignment: Alignment.center,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [_colorAnimation1.value!, _colorAnimation2.value!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.wechat_sharp,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        iconSize: 30,
        inactiveColor: Colors.white,
        icons: iconList,
        activeColor: Colors.grey.shade50,
        activeIndex: bottomNavInde,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) => setState(() => bottomNavInde = index),
        backgroundColor: const Color.fromARGB(255, 3, 22, 60),
      ),
      body: bottomPages[bottomNavInde],
    );
  }
}
