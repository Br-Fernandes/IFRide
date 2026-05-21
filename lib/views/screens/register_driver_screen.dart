import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/controllers/register_driver_controller.dart';

class RegisterDriverScreen extends StatelessWidget {
  RegisterDriverScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(RegisterDriverController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.025,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: size.height * 0.03),
                _buildInfoCard(),
                SizedBox(height: size.height * 0.025),
                _buildSectionTitle('Dados da Habilitação'),
                const SizedBox(height: 12),
                _buildCnhField(),
                const SizedBox(height: 12),
                _buildCategoryDropdown(context, primaryColor),
                const SizedBox(height: 12),
                _buildExpirationPicker(context, primaryColor),
                const Spacer(),
                _buildCheckStatusButton(context, primaryColor),
                const SizedBox(height: 10),
                _buildSubmitButton(context, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tornar-se Motorista',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Envie sua solicitação para análise',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Após o envio, um administrador irá analisar sua solicitação. Quando aprovada, você poderá cadastrar veículos e oferecer caronas.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
  }

  Widget _buildCnhField() {
    return TextFormField(
      onSaved: (v) => controller.cnhNumber.value = v ?? '',
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Informe o número da CNH.';
        if (v.trim().length != 11) return 'CNH deve ter exatamente 11 dígitos.';
        return null;
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration('Número da CNH (11 dígitos)', Icons.badge_outlined),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, Color primaryColor) {
    return DropdownButtonFormField<String>(
      initialValue: controller.cnhCategory.value,
      decoration: _inputDecoration('Categoria da CNH', Icons.category_outlined),
      items: controller.cnhCategories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) {
        if (val != null) controller.cnhCategory.value = val;
      },
    );
  }

  Widget _buildExpirationPicker(BuildContext context, Color primaryColor) {
    return Obx(() => GestureDetector(
          onTap: () => controller.selectExpiration(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black54),
                const SizedBox(width: 12),
                Text(
                  controller.cnhExpiration.value == null
                      ? 'Validade da CNH *'
                      : controller.formattedExpiration,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.cnhExpiration.value == null
                        ? Colors.black54
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildCheckStatusButton(BuildContext context, Color primaryColor) {
    final authController = Get.find<AuthController>();
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: authController.isCheckingRole.value
                ? null
                : () async {
                    final canCheck = await authController.refreshRoleFromBackend();
                    if (!canCheck) {
                      // userId não disponível — re-login resolve
                      Get.dialog(AlertDialog(
                        title: const Text('Reconexão necessária'),
                        content: const Text(
                            'Saia e entre novamente para sincronizar seu status de motorista.'),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancelar')),
                          ElevatedButton(
                              onPressed: () {
                                Get.back();
                                authController.logout();
                              },
                              child: const Text('Sair agora')),
                        ],
                      ));
                    } else if (authController.isDriver) {
                      Get.back();
                      Get.snackbar(
                        'Aprovado!',
                        'Sua solicitação foi aprovada. Agora você é motorista!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                      );
                    } else {
                      Get.snackbar(
                        'Ainda pendente',
                        'Sua solicitação ainda não foi aprovada.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange.shade700,
                        colorText: Colors.white,
                      );
                    }
                  },
            icon: authController.isCheckingRole.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(
              authController.isCheckingRole.value
                  ? 'Verificando...'
                  : 'Verificar status da solicitação',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ));
  }

  Widget _buildSubmitButton(BuildContext context, Color primaryColor) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: controller.isLoading.value
                ? null
                : () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    if (controller.cnhExpiration.value == null) {
                      Get.snackbar('Campo obrigatório', 'Selecione a data de validade da CNH.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade600,
                          colorText: Colors.white);
                      return;
                    }
                    _formKey.currentState?.save();
                    controller.submit();
                  },
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Enviar solicitação',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black87),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
