import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  const CityCard({super.key, required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size. width * 0.03),
            child: Row(
              children: [
                Image.asset(
                  "assets/map.png",
                  width: 50,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.07) ,
                Text(
                  cityName,
                  style: TextStyle(
                    color: Color(0xFF0B0A0A),
                    fontSize: 22
                  )
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.black
          ),
        ],
      ),
    );
  }
}
