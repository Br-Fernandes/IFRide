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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Suas caronas',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: "Passageiro"),
              Tab(text: "Motorista")
            ],
          )
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: _buildRideCard(
                      context: context,
                      date: "Sexta-Feira 20 de nov, 11:00",
                      origin: ride.origin,
                      destination: ride.destination,
                    ),
                  ),
                );
              },
            ),
            const Center(
              child: Text(
                'Você ainda não ofereceu caronas.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard({
    required BuildContext context,
    required String date,
    required String origin,
    required String destination,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Cor de fundo do card
          borderRadius: BorderRadius.circular(20.0), // Bordas arredondadas
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Visualizador da rota (bolinhas e linha)
                Column(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    Container(
                      height: 30,
                      width: 2,
                      color: Colors.red,
                    ),
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                  ],
                ),
                const SizedBox(width: 12),
                // Textos de origem e destino
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(origin, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 22),
                      Text(destination, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Ação do botão Detalhes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Detalhes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }  
}