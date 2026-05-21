import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/vehicle_controller.dart';
import 'package:if_ride/models/vehicle.dart';

class VehicleScreen extends StatelessWidget {
  VehicleScreen({super.key});

  final controller = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meus Veículos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVehicleSheet(context, primaryColor),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.vehicles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.vehicles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('Nenhum veículo cadastrado.',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _showAddVehicleSheet(context, primaryColor),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar veículo'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.vehicles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _VehicleCard(vehicle: controller.vehicles[i]),
        );
      }),
    );
  }

  void _showAddVehicleSheet(BuildContext context, Color primaryColor) {
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Adicionar Veículo',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _field(
                  label: 'Modelo (ex: Fiat Uno)',
                  icon: Icons.directions_car_outlined,
                  onSaved: (v) => controller.model.value = v ?? '',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o modelo.' : null,
                ),
                const SizedBox(height: 10),
                _field(
                  label: 'Placa (ex: ABC1D23)',
                  icon: Icons.pin_outlined,
                  onSaved: (v) => controller.plate.value = v ?? '',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe a placa.';
                    if (v.trim().length < 7) return 'Placa inválida.';
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [LengthLimitingTextInputFormatter(7)],
                ),
                const SizedBox(height: 10),
                _field(
                  label: 'Cor (ex: Prata)',
                  icon: Icons.palette_outlined,
                  onSaved: (v) => controller.color.value = v ?? '',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe a cor.' : null,
                ),
                const SizedBox(height: 10),
                Obx(() => Row(
                      children: [
                        const Icon(Icons.people_outline, size: 20, color: Colors.black54),
                        const SizedBox(width: 12),
                        const Text('Capacidade:', style: TextStyle(fontSize: 14)),
                        const Spacer(),
                        IconButton(
                          onPressed: controller.capacity.value > 1
                              ? () => controller.capacity.value--
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${controller.capacity.value}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: controller.capacity.value < 10
                              ? () => controller.capacity.value++
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    )),
                const SizedBox(height: 16),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (formKey.currentState?.validate() ?? false) {
                                  formKey.currentState?.save();
                                  controller.addVehicle();
                                }
                              },
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Cadastrar',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black26)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black87)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});
  final VehicleResponse vehicle;

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_car,
                color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.model,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text('${vehicle.plate} • ${vehicle.color}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
