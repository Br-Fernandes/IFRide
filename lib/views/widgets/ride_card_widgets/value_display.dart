import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/value_selector_controller.dart';

class ValueDisplay extends StatelessWidget {
  ValueDisplay({Key? key}) : super(key: key);

  final ValueController controller = Get.put(ValueController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Valor:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),  
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            controller.isEditing.value = true;
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: [
              // Texto visível
              Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Text("R\$ ", style: TextStyle(fontSize: 22)),
                      Text(
                        controller.value.value,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                );
              }),
              
              // TextField INVISÍVEL que captura o teclado
              Obx(() {
                if (!controller.isEditing.value) return const SizedBox.shrink();
                
                return Positioned.fill(
                  child: Opacity(
                    opacity: 0, // Totalmente invisível
                    child: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (text) {
                        controller.updateValue(text);
                      },
                      onEditingComplete: () {
                        controller.isEditing.value = false;
                      },
                      onSubmitted: (_) {
                        controller.isEditing.value = false;
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}