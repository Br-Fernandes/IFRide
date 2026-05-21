import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/services/ride_service.dart';
import 'package:if_ride/utils/cities.dart';
import 'package:if_ride/views/screens/ride_detail_screen.dart';
import 'package:if_ride/views/widgets/city_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _rideService = RideService();

  String? _selectedDestination;
  List<RideResponse> _rides = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _searchRides(String destination) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedDestination = destination;
    });
    try {
      final results = await _rideService.searchRides(destination: destination);
      setState(() => _rides = results);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    setState(() {
      _selectedDestination = null;
      _rides = [];
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedDestination == null
                          ? 'Selecione seu destino'
                          : 'Caronas para $_selectedDestination',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size.width * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_selectedDestination != null)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: Container(
                  color: Colors.white,
                  child: _selectedDestination == null
                      ? _buildCityList(size)
                      : _buildRideList(size),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityList(Size size) {
    return ListView.builder(
      padding: EdgeInsets.only(top: size.height * 0.02, bottom: size.height * 0.02),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        return CityCard(
          cityName: cities[index],
          onTap: () => _searchRides(cities[index]),
        );
      },
    );
  }

  Widget _buildRideList(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextButton(onPressed: () => _searchRides(_selectedDestination!), child: const Text('Tentar novamente')),
          ],
        ),
      );
    }
    if (_rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhuma carona disponível para $_selectedDestination.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04, vertical: size.height * 0.02),
      itemCount: _rides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _RideCard(
        ride: _rides[i],
        onTap: () => Get.to(() => RideDetailScreen(ride: _rides[i])),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driver.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(ride.vehicle.model,
                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    'R\$ ${ride.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 10),
                    Container(height: 24, width: 2, color: Colors.grey.shade300),
                    const Icon(Icons.circle, color: Colors.red, size: 10),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.origin, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 12),
                      Text(ride.destination, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text('${ride.availableSeats} vagas',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
