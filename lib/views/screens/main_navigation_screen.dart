import 'package:flutter/material.dart';
import 'package:if_ride/views/screens/account_screen.dart';
import 'package:if_ride/views/screens/conversations_screen.dart';
import 'package:if_ride/views/screens/home_screen.dart';
import 'package:if_ride/views/screens/new_ride_screen.dart';
import 'package:if_ride/views/screens/your_rides_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {

  int _currentIndex = 0; 

  PageController _pageController = PageController();

  final _bottomNavigationBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_sharp,), label: "Início"),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle,), label: "Oferecer"),
    BottomNavigationBarItem(icon: Icon(Icons.directions_car,), label: "Suas caronas"),
    BottomNavigationBarItem(icon: Icon(Icons.mail,), label: "Mensagens"),
    BottomNavigationBarItem(icon: Icon(Icons.person,), label: "Conta"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        children: [
          HomeScreen(),
          NewRideScreen(),
          YourRidesScreen(),
          ConversationsScreen(),
          AccountScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavigationBarItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        selectedLabelStyle: TextStyle(fontSize: 12), 
        unselectedLabelStyle: TextStyle(fontSize: 12),
        backgroundColor: Colors.white,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}