import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'discover_screen.dart';
import 'my_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    DiscoverScreen(),
    MyListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF081426),
        indicatorColor: const Color(0xFF173B70),
        selectedIndex: selectedIndex,

        // Mengatur efek klik / hover
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          // Kalau sudah terpilih, jangan timpa indicator
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }

          // Item yang belum dipilih tetap mendapat efek klik
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withOpacity(0.12);
          }

          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.06);
          }

          return Colors.transparent;
        }),

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Discover',
          ),

          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'My List',
          ),
        ],
      ),
    );
  }
}
