import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/services/ride_service.dart';
import 'package:if_ride/views/screens/ride_detail_screen.dart';

class YourRidesScreen extends StatefulWidget {
  const YourRidesScreen({super.key});

  @override
  State<YourRidesScreen> createState() => _YourRidesScreenState();
}

class _YourRidesScreenState extends State<YourRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _rideService = RideService();

  List<RideResponse> _passengerRides = [];
  bool _isLoadingPassenger = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPassengerRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPassengerRides() async {
    setState(() => _isLoadingPassenger = true);
    try {
      final rides = await _rideService.searchRides();
      setState(() => _passengerRides = rides);
    } catch (_) {
      setState(() => _passengerRides = []);
    } finally {
      setState(() => _isLoadingPassenger = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suas caronas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Passageiro'),
            Tab(text: 'Motorista'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPassengerTab(),
          _buildDriverTab(),
        ],
      ),
    );
  }

  Widget _buildPassengerTab() {
    if (_isLoadingPassenger) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_passengerRides.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma carona disponível no momento.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPassengerRides,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _passengerRides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _RideCard(
          ride: _passengerRides[i],
          onTap: () => Get.to(() => RideDetailScreen(ride: _passengerRides[i])),
        ),
      ),
    );
  }

  Widget _buildDriverTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Crie caronas pela aba "Oferecer"\npara visualizá-las aqui.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.ride, required this.onTap});
  final RideResponse ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Column(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 10),
                Container(height: 28, width: 2, color: Colors.grey.shade300),
                const Icon(Icons.circle, color: Colors.red, size: 10),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride.origin, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(ride.destination, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${ride.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text('${ride.availableSeats} vagas',
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
