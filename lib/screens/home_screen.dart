import 'package:flutter/material.dart';
import 'package:agrigest/screens/clients_screen.dart';
import 'package:agrigest/screens/taches_screen.dart';
import 'package:agrigest/screens/depenses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Using lazy initialization for better performance
  late final List<Widget> _screens = [
    const ClientsScreen(),
    const TachesScreen(),
    const DepensesScreen(),
  ];

  // Pre-built navigation items for better maintainability
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'Clients',
      tooltip: 'Gestion des clients',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_outlined),
      activeIcon: Icon(Icons.list),
      label: 'Tâches',
      tooltip: 'Gestion des tâches',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.money_off_outlined),
      activeIcon: Icon(Icons.money_off),
      label: 'Dépenses',
      tooltip: 'Gestion des dépenses',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriGest by Med Bouharb'),
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).disabledColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      items: _navItems,
    );
  }
}