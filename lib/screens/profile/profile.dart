import 'package:flutter/material.dart';
import 'package:junubullion/screens/profile/leftmenu.dart';
import 'package:junubullion/screens/profile/rightmenu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: LeftMenu(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),

            const VerticalDivider(width: 1),

            Expanded(flex: 7, child: RightMenu(selectedIndex: selectedIndex)),
          ],
        ),
      ),
    );
  }
}
