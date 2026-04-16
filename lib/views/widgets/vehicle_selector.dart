import 'package:flutter/material.dart';

// Lista de veículos — futuramente substituída por dados da API (veículos do usuário)
const List<Map<String, dynamic>> vehicleOptions = [
  {'label': 'Carro',     'icon': Icons.directions_car},
  {'label': 'Moto',      'icon': Icons.two_wheeler},
  {'label': 'Van/Kombi', 'icon': Icons.airport_shuttle},
  {'label': 'Pickup',    'icon': Icons.local_shipping},
];

class VehicleSelector extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;

  const VehicleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleSheet(
        selectedValue: value,
        onSelected: (v) {
          onChanged(v);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = vehicleOptions.firstWhere(
      (v) => v['label'] == value,
      orElse: () => {},
    );
    final hasValue = selected.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Veículo",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        GestureDetector(
          onTap: () => _openSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(45),
            ),
            child: Row(
              children: [
                Icon(
                  hasValue ? selected['icon'] as IconData : Icons.directions_car_outlined,
                  color: hasValue ? Colors.black87 : Colors.black45,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue ? selected['label'] as String : "Selecione o Veículo",
                    style: TextStyle(
                      fontSize: 16,
                      color: hasValue ? Colors.black87 : Colors.black45,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleSheet extends StatelessWidget {
  const _VehicleSheet({
    required this.selectedValue,
    required this.onSelected,
  });

  final String? selectedValue;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Selecione o veículo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...vehicleOptions.map((vehicle) {
            final label = vehicle['label'] as String;
            final icon = vehicle['icon'] as IconData;
            final isSelected = label == selectedValue;

            return InkWell(
              onTap: () => onSelected(label),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: isSelected ? primaryColor : Colors.black54),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      Icon(Icons.check_circle, color: primaryColor, size: 20),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
