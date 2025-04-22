import 'package:flutter/material.dart';
import 'package:if_ride/views/widgets/next_step_button.dart';

class SteptwoRide extends StatelessWidget {
  const SteptwoRide({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RideCard(),
          NextStepButton()
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      elevation: 8,
      color: Color(0xFFE8E7E7),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      
      child: Container(
        height: size.height * 0.7,
        width: size.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
        ),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardHeader(),
              //const SizedBox(height: 20),
              const _TimeSelector(),
              //const SizedBox(height: 20),
              const _PassengerSelector(),
              //const SizedBox(height: 20),
              const _ValueDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1),
        ),
      ),
      child: const Center(
        child: Text(
          "Detalhes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Selecione o hor\u00e1rio de sua viagem",
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
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
              side: const BorderSide(width: 3, color: Colors.black),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.watch_later_outlined, size: 45.0),
                SizedBox(width: 8),
                Text("00:00", style: TextStyle(fontSize: 25)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PassengerSelector extends StatelessWidget {
  const _PassengerSelector();

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

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay();

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
        InkWell(
          customBorder: const OutlineInputBorder(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text("00,00", style: TextStyle(fontSize: 22)),
          ),
        ),
      ],
    );
  }
}