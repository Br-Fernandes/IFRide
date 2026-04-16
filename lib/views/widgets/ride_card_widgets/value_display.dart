import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/value_selector_controller.dart';

class ValueDisplay extends StatelessWidget {
  ValueDisplay({Key? key}) : super(key: key);

  final ValueController controller = Get.put(ValueController());

  void _openValueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ValueInputSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openValueSheet(context),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Valor:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "R\$ ${controller.formattedValue}",
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ],
      )),
    );
  }
}

class _ValueInputSheet extends StatelessWidget {
  const _ValueInputSheet({required this.controller});

  final ValueController controller;

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
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Label
          Text(
            "Valor da carona",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Display do valor
          Obx(() => Text(
            "R\$ ${controller.formattedValue}",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: controller.cents > 0 ? Colors.black : Colors.grey.shade400,
            ),
          )),
          const SizedBox(height: 28),

          // Teclado numérico
          _buildNumpad(context, primaryColor),
          const SizedBox(height: 20),

          // Botão confirmar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Confirmar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad(BuildContext context, Color primaryColor) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.map((key) {
              if (key.isEmpty) return const Expanded(child: SizedBox());

              final isBackspace = key == '⌫';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: Material(
                      color: isBackspace
                          ? Colors.grey.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (isBackspace) {
                            controller.backspace();
                          } else {
                            controller.addDigit(key);
                          }
                        },
                        child: Center(
                          child: isBackspace
                              ? Icon(
                                  Icons.backspace_outlined,
                                  size: 22,
                                  color: Colors.grey.shade700,
                                )
                              : Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
