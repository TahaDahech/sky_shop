import 'package:flutter/material.dart';

import '../../widgets/common/footer.dart';
import '../../widgets/common/top_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const TopBar(),
          const SliverFillRemaining(
            child: Center(
              child: Text('Profile'),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: const Footer(),
            ),
          ),
        ],
      ),
    );
  }
}


