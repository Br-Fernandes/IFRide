import 'package:flutter/material.dart';

class YourRidesScreen extends StatelessWidget {
  YourRidesScreen({super.key});

  final ride = (
    dateTime: DateTime(2025, 9,15, 9, 0),
    origin: "Orizona",
    destination: "IF Goiano"
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suas Caronas"),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(7),
            color: Color(0xFFE8E7E7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${ride.dateTime}"),
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text("${ride.origin}"),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: 12,
                  color: Colors.red,
                ),
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text("${ride.destination}"),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.047,
                  width: MediaQuery.of(context).size.width * 0.5 ,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Detalhes",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}