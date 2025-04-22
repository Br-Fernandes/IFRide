import 'package:flutter/material.dart';
import 'package:if_ride/utils/cities.dart';
import 'package:if_ride/views/widgets/city_card.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "Selecione seu destino",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45),
              topRight: Radius.circular(45)
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: 45.0
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              color: Colors.white,
              child: Column(
                children: cities.map((city) => CityCard(cityName: city,)).toList(),
              )
            ),
          ),
        ],
      ),
    ); 
  }
}