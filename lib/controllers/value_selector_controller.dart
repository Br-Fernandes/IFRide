import 'package:get/get.dart';

class ValueController extends GetxController {
  RxString value = "00,00".obs;
  RxBool isEditing = false.obs;
  
  void updateValue(String newValue) {
    // Remove tudo que não é número
    String numbers = newValue.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 4 dígitos
    if (numbers.length > 4) {
      numbers = numbers.substring(numbers.length - 4);
    }
    
    // Adiciona zeros à esquerda
    numbers = numbers.padLeft(4, '0');
    
    // Formata "00,00"
    String reais = numbers.substring(0, 2);
    String centavos = numbers.substring(2);
    
    value.value = "$reais,$centavos";
  }
}