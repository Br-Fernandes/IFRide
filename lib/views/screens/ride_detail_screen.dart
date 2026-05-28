import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/services/ride_service.dart';
import 'package:if_ride/views/screens/chat_screen.dart';

class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key, required this.ride});
  final RideResponse ride;

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final _rideService = RideService();
  bool _isRequesting = false;

  List<RideParticipantResponse> _participants = [];
  bool _isLoadingParticipants = false;
  final Set<String> _processingIds = {};

  bool get _isOwner {
    final userId = Get.find<AuthController>().user?.id;
    return userId != null && userId == widget.ride.driver.id;
  }

  @override
  void initState() {
    super.initState();
    if (_isOwner) _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    if (widget.ride.id == null) return;
    setState(() => _isLoadingParticipants = true);
    try {
      final list = await _rideService.getRideParticipants(widget.ride.id!);
      setState(() => _participants = list);
    } catch (_) {
    } finally {
      setState(() => _isLoadingParticipants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final ride = widget.ride;
    final isDriver = Get.find<AuthController>().isDriver;

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
            const SizedBox(height: 20),
            if (_isOwner)
              _ParticipantsSection(
                participants: _participants,
                isLoading: _isLoadingParticipants,
                processingIds: _processingIds,
                primaryColor: primaryColor,
                onAccept: _acceptParticipant,
                onReject: _rejectParticipant,
              )
            else if (!isDriver && ride.id == null)
              _LimitationNote()
            else if (!isDriver && ride.id != null)
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
    _doRequestSeat(ride.id!, ride.origin);
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

  Future<void> _acceptParticipant(RideParticipantResponse participant) async {
    final participantId = participant.id!;
    if (_processingIds.contains(participantId)) return;
    setState(() => _processingIds.add(participantId));
    try {
      await _rideService.acceptParticipant(participantId);
      if (!mounted) return;
      Get.to(() => ChatScreen(
            rideId: widget.ride.id!,
            recipientId: participant.passengerId,
            recipientName: participant.passengerName,
          ));
      _loadParticipants();
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _processingIds.remove(participantId));
    }
  }

  Future<void> _rejectParticipant(String participantId) async {
    if (_processingIds.contains(participantId)) return;
    setState(() => _processingIds.add(participantId));
    try {
      await _rideService.rejectParticipant(participantId);
      Get.snackbar('Rejeitado', 'Solicitação rejeitada.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white);
      _loadParticipants();
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _processingIds.remove(participantId));
    }
  }
}

// ── seção de participantes (visível só para o motorista dono da carona) ────────

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection({
    required this.participants,
    required this.isLoading,
    required this.processingIds,
    required this.primaryColor,
    required this.onAccept,
    required this.onReject,
  });

  final List<RideParticipantResponse> participants;
  final bool isLoading;
  final Set<String> processingIds;
  final Color primaryColor;
  final void Function(RideParticipantResponse) onAccept;
  final void Function(String) onReject;

  @override
  Widget build(BuildContext context) {
    final pending =
        participants.where((p) => p.status == 'PENDING').toList();
    final accepted =
        participants.where((p) => p.status == 'ACCEPTED').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Solicitações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (pending.isEmpty && accepted.isEmpty)
          _emptyNote('Nenhuma solicitação ainda.')
        else ...[
          if (pending.isNotEmpty) ...[
            _sectionLabel('Aguardando resposta', Colors.orange),
            const SizedBox(height: 8),
            ...pending.map((p) {
              final isProcessing = p.id != null && processingIds.contains(p.id);
              return _ParticipantCard(
                participant: p,
                primaryColor: primaryColor,
                isProcessing: isProcessing,
                onAccept: (p.id != null && !isProcessing) ? () => onAccept(p) : null,
                onReject: (p.id != null && !isProcessing) ? () => onReject(p.id!) : null,
              );
            }),
          ],
          if (accepted.isNotEmpty) ...[
            if (pending.isNotEmpty) const SizedBox(height: 12),
            _sectionLabel('Aceitos', Colors.green),
            const SizedBox(height: 8),
            ...accepted.map((p) => _ParticipantCard(
                  participant: p,
                  primaryColor: primaryColor,
                )),
          ],
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sectionLabel(String text, Color color) => Row(children: [
        Container(width: 4, height: 14, color: color,
            margin: const EdgeInsets.only(right: 8)),
        Text(text,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]);

  Widget _emptyNote(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(msg,
            style: const TextStyle(color: Colors.black45, fontSize: 13)),
      );
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.participant,
    required this.primaryColor,
    this.isProcessing = false,
    this.onAccept,
    this.onReject,
  });

  final RideParticipantResponse participant;
  final Color primaryColor;
  final bool isProcessing;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Text(
              participant.passengerName.isNotEmpty
                  ? participant.passengerName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(participant.passengerName,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          if (isProcessing)
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (onAccept != null && onReject != null) ...[
            _iconBtn(icon: Icons.check, color: Colors.green, onTap: onAccept!),
            const SizedBox(width: 6),
            _iconBtn(icon: Icons.close, color: Colors.red, onTap: onReject!),
          ],
        ],
      ),
    );
  }

  Widget _iconBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ── cards existentes ──────────────────────────────────────────────────────────

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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('CNH: ${ride.driver.cnhCategory}',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${ride.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor),
              ),
              Text('${ride.availableSeats} vagas',
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 12)),
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
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _routeStop(
              icon: Icons.radio_button_checked,
              color: Colors.green,
              label: ride.origin),
          ...ride.pickupPoints.map((p) => _routeStop(
              icon: Icons.location_on_outlined,
              color: Colors.orange,
              label: p)),
          _routeStop(
              icon: Icons.location_on,
              color: Colors.red,
              label: ride.destination),
        ],
      ),
    );
  }

  Widget _routeStop(
      {required IconData icon,
      required Color color,
      required String label}) {
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
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_car_outlined,
                  size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                  '${ride.vehicle.model} • ${ride.vehicle.plate} • ${ride.vehicle.color}',
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isRequesting ? null : onRequest,
        icon: isRequesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.add_circle_outline),
        label: Text(
          isRequesting ? 'Enviando...' : 'Solicitar vaga',
          style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
