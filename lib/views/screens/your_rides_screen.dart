import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/services/ride_service.dart';
import 'package:if_ride/views/screens/ride_detail_screen.dart';
import 'package:intl/intl.dart';

class YourRidesScreen extends StatefulWidget {
  const YourRidesScreen({super.key});

  @override
  State<YourRidesScreen> createState() => _YourRidesScreenState();
}

class _YourRidesScreenState extends State<YourRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _rideService = RideService();

  List<RideParticipantResponse> _passengerRides = [];
  List<RideResponse> _driverRides = [];
  bool _isLoadingPassenger = false;
  bool _isLoadingDriver = false;
  String? _passengerError;
  String? _driverError;

  bool get _isDriver =>
      Get.find<AuthController>().isDriver;

  @override
  void initState() {
    super.initState();
    // Motorista começa na aba "Motorista" (índice 1), passageiro na "Passageiro" (índice 0)
    final initialIndex = _isDriver ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _loadPassengerRides();
    if (_isDriver) _loadDriverRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPassengerRides() async {
    setState(() { _isLoadingPassenger = true; _passengerError = null; });
    try {
      final rides = await _rideService.getMyPassengerRides();
      setState(() => _passengerRides = rides);
    } catch (e) {
      setState(() {
        _passengerRides = [];
        _passengerError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoadingPassenger = false);
    }
  }

  Future<void> _loadDriverRides() async {
    setState(() { _isLoadingDriver = true; _driverError = null; });
    try {
      final rides = await _rideService.getMyDriverRides();
      setState(() => _driverRides = rides);
    } catch (e) {
      setState(() {
        _driverRides = [];
        _driverError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoadingDriver = false);
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
    if (_passengerError != null) {
      return _ErrorState(message: _passengerError!, onRetry: _loadPassengerRides);
    }
    if (_passengerRides.isEmpty) {
      return const _EmptyState(
        icon: Icons.person_outline,
        message: 'Você ainda não solicitou\nvagas em nenhuma carona.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPassengerRides,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _passengerRides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _passengerRides[i];
          return _PassengerRideCard(
            participation: p,
            onTap: () => Get.to(() => RideDetailScreen(ride: p.ride, participation: p)),
          );
        },
      ),
    );
  }

  Widget _buildDriverTab() {
    if (!_isDriver) {
      return const _EmptyState(
        icon: Icons.directions_car_outlined,
        message: 'Apenas motoristas podem\ncriar caronas.',
      );
    }
    if (_isLoadingDriver) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_driverError != null) {
      return _ErrorState(message: _driverError!, onRetry: _loadDriverRides);
    }
    if (_driverRides.isEmpty) {
      return const _EmptyState(
        icon: Icons.directions_car_outlined,
        message: 'Você ainda não criou\nnenhuma carona.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadDriverRides,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _driverRides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _DriverRideCard(
          ride: _driverRides[i],
          onTap: () => Get.to(() => RideDetailScreen(ride: _driverRides[i])),
        ),
      ),
    );
  }
}

// ── cards ─────────────────────────────────────────────────────────────────────

class _PassengerRideCard extends StatelessWidget {
  const _PassengerRideCard({required this.participation, required this.onTap});
  final RideParticipantResponse participation;
  final VoidCallback onTap;

  Color _statusColor(String status) => switch (status) {
        'ACCEPTED' => Colors.green,
        'PENDING' => Colors.orange,
        'REJECTED' => Colors.red,
        'CANCELLED' => Colors.grey,
        _ => Colors.grey,
      };

  String _statusLabel(String status) => switch (status) {
        'ACCEPTED' => 'Aceito',
        'PENDING' => 'Pendente',
        'REJECTED' => 'Rejeitado',
        'CANCELLED' => 'Cancelado',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final ride = participation.ride;
    final statusColor = _statusColor(participation.status);

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
            Column(children: [
              const Icon(Icons.circle, color: Colors.green, size: 10),
              Container(height: 28, width: 2, color: Colors.grey.shade300),
              const Icon(Icons.circle, color: Colors.red, size: 10),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ride.origin,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text(ride.destination,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                'R\$ ${ride.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(participation.status),
                  style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DriverRideCard extends StatelessWidget {
  const _DriverRideCard({required this.ride, required this.onTap});
  final RideResponse ride;
  final VoidCallback onTap;

  Color _statusColor(String? s) => switch (s) {
        'SCHEDULED' => Colors.blue,
        'IN_PROGRESS' => Colors.green,
        'FULL' => Colors.orange,
        'FINISHED' => Colors.grey,
        'CANCELLED' => Colors.red,
        _ => Colors.grey,
      };

  String _statusLabel(String? s) => switch (s) {
        'SCHEDULED' => 'Agendada',
        'IN_PROGRESS' => 'Em andamento',
        'FULL' => 'Lotada',
        'FINISHED' => 'Finalizada',
        'CANCELLED' => 'Cancelada',
        _ => s ?? '',
      };

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final statusColor = _statusColor(ride.rideStatus);
    final dateStr = ride.departureTime != null
        ? DateFormat('dd/MM/yy HH:mm').format(ride.departureTime!)
        : '';

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
            Column(children: [
              const Icon(Icons.circle, color: Colors.green, size: 10),
              Container(height: 28, width: 2, color: Colors.grey.shade300),
              const Icon(Icons.circle, color: Colors.red, size: 10),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ride.origin,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text(ride.destination,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                'R\$ ${ride.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(ride.rideStatus),
                  style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (dateStr.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(dateStr,
                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}

// ── estados ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar novamente'),
          ),
        ]),
      ),
    );
  }
}
