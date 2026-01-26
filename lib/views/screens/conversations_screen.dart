import 'package:flutter/material.dart';
import 'package:if_ride/models/user.dart';
import 'package:if_ride/views/widgets/chat_widgets/chat_card.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Suas Conversas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: mockUsers.length,
        itemBuilder: (context, index) {
          return ChatCard(user: mockUsers[index], message: "Ultima mensagem",);
        },
      ),
    );
  }
}

final List<User> mockUsers = [
  User(id: 'mock-id-1', name: 'Usuário Logado', email: "", imageUrl: "", city: "Orizona"),
  User(id: 'mock-id-2', name: 'Usuário 2', email: "", imageUrl: "", city: "Orizona"),
  User(id: 'mock-id-3', name: 'Usuário 3', email: "", imageUrl: "", city: "Orizona")
];
