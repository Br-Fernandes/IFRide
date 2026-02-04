import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/passenger_selector_controller.dart';

class PassengerSelector extends StatelessWidget {
  PassengerSelector({Key? key}) : super(key: key);

  final PassengerSelectorController controller = 
      Get.put(PassengerSelectorController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      return Column(
        children: [
          const Text(
            "Quantidade de vagas disponíveis",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.07,
                width: size.width * 0.3,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: Theme.of(context).canvasColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.person, size: Get.height * 0.06),
                    Text(
                      controller.passengerCount.value.toString(),
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.05),
              Column(
                children: [
                  InkWell(
                    onTap: controller.canIncrement 
                        ? controller.increment 
                        : null,
                    child: Container(
                      height: Get.height * 0.06,
                      width: Get.height * 0.06,
                      decoration: BoxDecoration(
                        color: controller.canIncrement
                            ? Theme.of(context).canvasColor
                            : const Color.fromARGB(50, 191, 215, 106),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: controller.canIncrement
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: controller.canDecrement 
                        ? controller.decrement 
                        : null,
                    child: Container(
                      height: Get.height * 0.06,
                      width: Get.height * 0.06,
                      decoration: BoxDecoration(
                        color: controller.canDecrement
                            ? const Color.fromARGB(255, 191, 236, 106)
                            : const Color.fromARGB(50, 191, 215, 106),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: controller.canDecrement
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }
}