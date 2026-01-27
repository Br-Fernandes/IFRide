import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/user.dart';

class AccountScreen extends StatelessWidget {

  AccountScreen({super.key});

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02, vertical: Get.height * 0.04),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      user.name,
                      maxFontSize: 25,
                      minFontSize: 17,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    AutoSizeText(
                      user.city,
                      maxFontSize: 20,
                      minFontSize: 12,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
                CircleAvatar(
                  radius: Get.height * 0.05,
                  backgroundImage:
                      user.imageUrl != null ? NetworkImage(user.imageUrl!) : null,
                  child: user.imageUrl == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.04,),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Alterar foto de perfil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height * 0.02,),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                     "Alterar dados pessoais",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).primaryColor
                     ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: Get.width * 0.02, vertical: Get.height * 0.04),
              height: 1,
              color: Colors.grey,
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                     "Sair",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Colors.black
                     ),
                    ),
                  ),
                  SizedBox(height: Get.height * 0.03,),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                     "Excluir conta",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Colors.red
                     ),
                    ),
                  )  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final user = User(id: 'mock-id-1', name: 'Usuário Logado', email: "", imageUrl: "", city: "Orizona");
}

