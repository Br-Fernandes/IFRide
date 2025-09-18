import 'package:flutter/material.dart';

class PassengerSelector extends StatelessWidget {
  const PassengerSelector();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        const Text(
          "N\u00famero de passageiros dispon\u00edveis",
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.person, size: 45.0,),
                  Text("1", style: TextStyle(fontSize: 25)),
                  SizedBox(),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Column(
              children: [
                InkWell(
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Theme.of(context).canvasColor,
                    child: const Icon(Icons.add),
                  ),
                ),
                const SizedBox(height: 15),
                InkWell(
                  child: Container(
                    height: 50,
                    width: 50,
                    color: const Color.fromARGB(255, 191, 236, 106),
                    child: const Icon(Icons.remove),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

