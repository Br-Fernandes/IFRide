import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
import 'package:if_ride/views/widgets/next_step_button.dart';

class StepThreeRide extends StatelessWidget {
  StepThreeRide({super.key});

  final controller = Get.find<NewRideController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: controller.weekDays.length,
            itemBuilder: (context, index) {
              return _DayCard(dayConfig: controller.weekDays[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(child: NextStepButton()),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.dayConfig});

  final DayRideConfig dayConfig;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: dayConfig.time.value,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dayConfig.time.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEnabled = dayConfig.enabled.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isEnabled ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header: nome do dia + checkbox
            InkWell(
              onTap: () => dayConfig.enabled.value = !isEnabled,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      dayConfig.dayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Checkbox(
                      value: isEnabled,
                      onChanged: (val) => dayConfig.enabled.value = val ?? false,
                      activeColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Conteúdo expandido quando habilitado
            if (isEnabled) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha de labels
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Selecione o horário de sua viagem",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Número de passageiros disponíveis",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Linha de controles: horário | passageiros
                    Row(
                      children: [
                        // Botão de horário
                        Expanded(
                          child: Obx(() => InkWell(
                            onTap: () => _pickTime(context),
                            borderRadius: BorderRadius.circular(45),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.circular(45),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.watch_later_outlined, size: 22),
                                  const SizedBox(width: 6),
                                  Text(
                                    dayConfig.formattedTime,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ),
                        const SizedBox(width: 12),

                        // Seletor de passageiros
                        Expanded(
                          child: Obx(() => Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.circular(45),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.person, size: 26),
                                      const SizedBox(width: 4),
                                      Text(
                                        dayConfig.passengerCount.value.toString(),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                children: [
                                  _CounterButton(
                                    icon: Icons.add,
                                    enabled: dayConfig.canIncrement,
                                    onTap: dayConfig.increment,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  const SizedBox(height: 6),
                                  _CounterButton(
                                    icon: Icons.remove,
                                    enabled: dayConfig.canDecrement,
                                    onTap: dayConfig.decrement,
                                    color: const Color.fromARGB(255, 191, 236, 106),
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Campo de valor
                    Row(
                      children: [
                        const Text(
                          "Valor:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dayConfig.formattedPrice,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )),
                        ),
                        const SizedBox(width: 8),
                        // Botão de editar valor
                        InkWell(
                          onTap: () => _showPriceDialog(context),
                          child: const Icon(Icons.edit, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Indicador de colapso
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showPriceDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Definir valor"),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: "R\$ ",
            hintText: "0",
            suffixText: ",00",
          ),
          onChanged: (v) {
            final reais = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            dayConfig.priceCents.value = reais * 100;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
