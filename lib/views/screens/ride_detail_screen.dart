import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/services/ride_service.dart';

class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key, required this.ride});
  final RideResponse ride;

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final _rideService = RideService();
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final ride = widget.ride;
    final authController = Get.find<AuthController>();
    final isDriver = authController.isDriver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalhes da Carona',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DriverCard(ride: ride, primaryColor: primaryColor),
            const SizedBox(height: 20),
            _RouteCard(ride: ride, primaryColor: primaryColor),
            const SizedBox(height: 20),
            _DetailsCard(ride: ride, primaryColor: primaryColor),
            const SizedBox(height: 32),
            if (!isDriver && ride.id == null)
              _LimitationNote(),
            if (!isDriver && ride.id != null)
              _RequestSeatButton(
                ride: ride,
                isRequesting: _isRequesting,
                onRequest: _requestSeat,
                primaryColor: primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestSeat() async {
    final ride = widget.ride;
    if (ride.id == null) return;

    // Se a carona tem pontos de parada, pede ao usuário escolher
    if (ride.pickupPoints.isNotEmpty) {
      _showPickupPointSelector(ride);
    } else {
      await _doRequestSeat(ride.id!, ride.origin);
    }
  }

  void _showPickupPointSelector(RideResponse ride) {
    final options = [ride.origin, ...ride.pickupPoints];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Ponto de embarque',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...options.map((point) => ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(point),
                  onTap: () {
                    Navigator.pop(context);
                    _doRequestSeat(ride.id!, point);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _doRequestSeat(String rideId, String pickupPoint) async {
    setState(() => _isRequesting = true);
    try {
      await _rideService.requestSeat(rideId, pickupPoint);
      Get.snackbar(
        'Solicitação enviada!',
        'Aguarde o motorista aceitar sua entrada.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.ride, required this.primaryColor});
  final RideResponse ride;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride.driver.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('CNH: ${ride.driver.cnhCategory}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${ride.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
              ),
              Text('${ride.availableSeats} vagas',
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.ride, required this.primaryColor});
  final RideResponse ride;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rota',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _routeStop(icon: Icons.radio_button_checked, color: Colors.green, label: ride.origin),
          ...ride.pickupPoints.map((p) =>
              _routeStop(icon: Icons.location_on_outlined, color: Colors.orange, label: p)),
          _routeStop(icon: Icons.location_on, color: Colors.red, label: ride.destination),
        ],
      ),
    );
  }

  Widget _routeStop({required IconData icon, required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.ride, required this.primaryColor});
  final RideResponse ride;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Veículo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_car_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Text('${ride.vehicle.model} • ${ride.vehicle.plate} • ${ride.vehicle.color}',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LimitationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Para solicitar esta vaga, entre em contato com o motorista diretamente.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestSeatButton extends StatelessWidget {
  const _RequestSeatButton({
    required this.ride,
    required this.isRequesting,
    required this.onRequest,
    required this.primaryColor,
  });
  final RideResponse ride;
  final bool isRequesting;
  final VoidCallback onRequest;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isRequesting ? null : onRequest,
        icon: isRequesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.add_circle_outline),
        label: Text(
          isRequesting ? 'Enviando...' : 'Solicitar vaga',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
