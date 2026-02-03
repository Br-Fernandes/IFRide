import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/time_selector_controller.dart';

class TimeSelector extends StatelessWidget {
  TimeSelector({Key? key}) : super(key: key);
  
  final TimeSelectorController controller = Get.put(TimeSelectorController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimeSelectorController>(
      builder: (controller) {
        return Column(
          children: [
            const Text(
              "Selecione o horário de sua viagem",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(45),
              ),
              child: InkWell(
                onTap: () => controller.selectTime(),
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                  side: const BorderSide(width: 3, color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.watch_later_outlined, size: 45.0),
                    const SizedBox(width: 8),
                    Text(
                      controller.formattedTime,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}