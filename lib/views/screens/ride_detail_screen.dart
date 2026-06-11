import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/services/ride_service.dart';
import 'package:if_ride/views/screens/chat_screen.dart';

class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key, required this.ride, this.participation});
  final RideResponse ride;
  final RideParticipantResponse? participation;

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final _rideService = RideService();
  bool _isRequesting = false;

  List<RideParticipantResponse> _participants = [];
  bool _isLoadingParticipants = false;
  final Set<String> _processingIds = {};

  late String? _rideStatus;
  String? _participationStatus;
  String? _participationId;
  bool _isUpdatingRideStatus = false;
  bool _isCancellingParticipation = false;

  bool get _isOwner {
    final userId = Get.find<AuthController>().user?.id;
    return userId != null && userId == widget.ride.driver.id;
  }

  @override
  void initState() {
    super.initState();
    _rideStatus = widget.ride.rideStatus;
    _participationStatus = widget.participation?.status;
    _participationId = widget.participation?.id;
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
            if (_isOwner) ...[
              _RideStatusActions(
                status: _rideStatus,
                isProcessing: _isUpdatingRideStatus,
                onStart: _startRide,
                onFinish: _finishRide,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 20),
              _ParticipantsSection(
                participants: _participants,
                isLoading: _isLoadingParticipants,
                processingIds: _processingIds,
                primaryColor: primaryColor,
                onAccept: _acceptParticipant,
                onReject: _rejectParticipant,
              ),
            ] else if (!isDriver && ride.id == null)
              _LimitationNote()
            else if (!isDriver && ride.id != null)
              _PassengerParticipationSection(
                ride: ride,
                participationStatus: _participationStatus,
                isRequesting: _isRequesting,
                isCancelling: _isCancellingParticipation,
                onRequest: _requestSeat,
                onCancel: _cancelParticipation,
                onOpenChat: _openChat,
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

  Future<void> _startRide() async {
    if (widget.ride.id == null || _isUpdatingRideStatus) return;
    setState(() => _isUpdatingRideStatus = true);
    try {
      await _rideService.startRide(widget.ride.id!);
      if (!mounted) return;
      setState(() => _rideStatus = 'IN_PROGRESS');
      Get.snackbar('Carona iniciada!', 'Boa viagem!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isUpdatingRideStatus = false);
    }
  }

  Future<void> _finishRide() async {
    if (widget.ride.id == null || _isUpdatingRideStatus) return;
    setState(() => _isUpdatingRideStatus = true);
    try {
      await _rideService.finishRide(widget.ride.id!);
      if (!mounted) return;
      setState(() => _rideStatus = 'FINISHED');
      Get.snackbar('Carona finalizada!', 'Obrigado por dirigir com a gente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isUpdatingRideStatus = false);
    }
  }

  Future<void> _cancelParticipation() async {
    final id = _participationId;
    if (id == null || _isCancellingParticipation) return;
    setState(() => _isCancellingParticipation = true);
    try {
      await _rideService.cancelParticipation(id);
      if (!mounted) return;
      setState(() => _participationStatus = 'CANCELLED');
      Get.snackbar('Participação cancelada', 'Sua vaga foi liberada.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isCancellingParticipation = false);
    }
  }

  void _openChat() {
    if (widget.ride.id == null) return;
    Get.to(() => ChatScreen(
          rideId: widget.ride.id!,
          recipientId: widget.ride.driver.id,
          recipientName: widget.ride.driver.name,
        ));
  }
}

// ── ações de status da carona (visível só para o motorista dono da carona) ─────

Color _rideStatusColor(String? status) => switch (status) {
      'SCHEDULED' => Colors.blue,
      'IN_PROGRESS' => Colors.green,
      'FULL' => Colors.orange,
      'FINISHED' => Colors.grey,
      'CANCELLED' => Colors.red,
      _ => Colors.grey,
    };

String _rideStatusLabel(String? status) => switch (status) {
      'SCHEDULED' => 'Agendada',
      'IN_PROGRESS' => 'Em andamento',
      'FULL' => 'Lotada',
      'FINISHED' => 'Finalizada',
      'CANCELLED' => 'Cancelada',
      _ => status ?? '',
    };

class _RideStatusActions extends StatelessWidget {
  const _RideStatusActions({
    required this.status,
    required this.isProcessing,
    required this.onStart,
    required this.onFinish,
    required this.primaryColor,
  });

  final String? status;
  final bool isProcessing;
  final VoidCallback onStart;
  final VoidCallback onFinish;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final color = _rideStatusColor(status);
    final badge = Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _rideStatusLabel(status),
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );

    Widget? actionButton;
    switch (status) {
      case 'SCHEDULED':
      case 'FULL':
        actionButton = _ActionButton(
          label: isProcessing ? 'Iniciando...' : 'Iniciar carona',
          icon: Icons.play_arrow_rounded,
          color: primaryColor,
          isLoading: isProcessing,
          onPressed: isProcessing ? null : onStart,
        );
        break;
      case 'IN_PROGRESS':
        actionButton = _ActionButton(
          label: isProcessing ? 'Finalizando...' : 'Finalizar carona',
          icon: Icons.flag_outlined,
          color: Colors.red.shade600,
          isLoading: isProcessing,
          onPressed: isProcessing ? null : onFinish,
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        badge,
        if (actionButton != null) ...[const SizedBox(height: 12), actionButton],
      ],
    );
  }
}

// ── seção de participação do passageiro ─────────────────────────────────────

class _PassengerParticipationSection extends StatelessWidget {
  const _PassengerParticipationSection({
    required this.ride,
    required this.participationStatus,
    required this.isRequesting,
    required this.isCancelling,
    required this.onRequest,
    required this.onCancel,
    required this.onOpenChat,
    required this.primaryColor,
  });

  final RideResponse ride;
  final String? participationStatus;
  final bool isRequesting;
  final bool isCancelling;
  final VoidCallback onRequest;
  final VoidCallback onCancel;
  final VoidCallback onOpenChat;
  final Color primaryColor;

  bool get _departed =>
      ride.departureTime != null && ride.departureTime!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    switch (participationStatus) {
      case 'PENDING':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StatusBanner(
              text: 'Aguardando resposta do motorista.',
              color: Colors.orange,
              icon: Icons.hourglass_empty,
            ),
            if (!_departed) ...[
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Cancelar solicitação',
                icon: Icons.close,
                color: Colors.red,
                outlined: true,
                isLoading: isCancelling,
                onPressed: isCancelling ? null : onCancel,
              ),
            ],
          ],
        );
      case 'ACCEPTED':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StatusBanner(
              text: 'Sua vaga foi aceita pelo motorista!',
              color: Colors.green,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Conversar com o motorista',
              icon: Icons.chat_bubble_outline,
              color: primaryColor,
              onPressed: onOpenChat,
            ),
            if (!_departed) ...[
              const SizedBox(height: 8),
              _ActionButton(
                label: 'Cancelar participação',
                icon: Icons.close,
                color: Colors.red,
                outlined: true,
                isLoading: isCancelling,
                onPressed: isCancelling ? null : onCancel,
              ),
            ],
          ],
        );
      case 'REJECTED':
        return const _StatusBanner(
          text: 'Sua solicitação foi recusada pelo motorista.',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        );
      case 'CANCELLED':
        return const _StatusBanner(
          text: 'Você cancelou sua participação nesta carona.',
          color: Colors.grey,
          icon: Icons.info_outline,
        );
      default:
        return _RequestSeatButton(
          ride: ride,
          isRequesting: isRequesting,
          onRequest: onRequest,
          primaryColor: primaryColor,
        );
    }
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.text,
    required this.color,
    this.icon = Icons.info_outline,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: outlined ? color : Colors.white,
      ),
    );
    final iconWidget = isLoading ? spinner : Icon(icon);
    final labelWidget =
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: shape,
              ),
              onPressed: onPressed,
              icon: iconWidget,
              label: labelWidget,
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: shape,
              ),
              onPressed: onPressed,
              icon: iconWidget,
              label: labelWidget,
            ),
    );
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
