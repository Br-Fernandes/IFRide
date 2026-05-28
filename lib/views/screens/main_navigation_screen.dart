import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/controllers/vehicle_controller.dart';
import 'package:if_ride/views/screens/account_screen.dart';
import 'package:if_ride/views/screens/conversations_screen.dart';
import 'package:if_ride/views/screens/home_screen.dart';
import 'package:if_ride/views/screens/new_ride_screen.dart';
import 'package:if_ride/views/screens/register_driver_screen.dart';
import 'package:if_ride/views/screens/your_rides_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final _pageController = PageController();
  late final AuthController _authController;

  final _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_sharp), label: 'Início'),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Oferecer'),
    BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Caronas'),
    BottomNavigationBarItem(icon: Icon(Icons.message),label: 'Mensagens'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Conta'),
  ];

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  // Verifica role sempre que o app volta do background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authController.refreshRoleFromBackend();
    }
  }

  Future<void> _onTabTapped(int index) async {
    if (index == 1) {
      // Antes de decidir, verifica se o role foi atualizado no backend
      await _authController.refreshRoleFromBackend();

      if (!_authController.isDriver) {
        Get.to(() => RegisterDriverScreen());
        return;
      }

      if (!Get.isRegistered<VehicleController>()) {
        Get.put(VehicleController());
      }
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: [
          const HomeScreen(),
          NewRideScreen(),
          const YourRidesScreen(),
          ConversationsScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final checking = _authController.isCheckingRole.value;
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          items: _navItems,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          backgroundColor: Colors.white,
          // Desabilita toque enquanto verifica role para evitar double-tap
          onTap: checking ? null : _onTabTapped,
        );
      }),
    );
  }
}