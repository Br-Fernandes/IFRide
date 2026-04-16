import 'package:flutter/material.dart';
import 'package:if_ride/utils/cities.dart';
import 'package:if_ride/views/widgets/city_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              child: Text(
                "Selecione seu destino",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.062,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: size.height * 0.02,
                      bottom: size.height * 0.02,
                    ),
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      return CityCard(cityName: cities[index]);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
