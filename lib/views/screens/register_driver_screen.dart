import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/register_driver_controller.dart';
import 'package:image_picker/image_picker.dart';

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
                _buildHeader(context),
                SizedBox(height: size.height * 0.025),
                _buildPhotoPicker(context, primaryColor),
                SizedBox(height: size.height * 0.025),
                _buildSectionTitle('Habilitação'),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Número da CNH',
                  icon: Icons.badge_outlined,
                  onSaved: (v) => controller.cnh.value = v ?? '',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o número da CNH.';
                    if (v.trim().length < 11) return 'CNH deve ter 11 dígitos.';
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                _buildSectionTitle('Veículo'),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Modelo (ex: Fiat Uno, Branco)',
                  icon: Icons.directions_car_outlined,
                  onSaved: (v) => controller.vehicleModel.value = v ?? '',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o modelo do veículo.';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Placa (ex: ABC1D23)',
                  icon: Icons.pin_outlined,
                  onSaved: (v) => controller.vehiclePlate.value = v ?? '',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe a placa do veículo.';
                    if (v.trim().length < 7) return 'Placa inválida.';
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                ),
                const Spacer(),
                _buildSubmitButton(context, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              'Cadastro de Motorista',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Preencha os dados para oferecer caronas',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPicker(BuildContext context, Color primaryColor) {
    return Obx(() {
      final photo = controller.profilePhoto.value;
      return Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showPhotoOptions(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: photo != null ? FileImage(photo) : null,
                    child: photo == null
                        ? Icon(Icons.person, size: 44, color: Colors.grey.shade400)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              photo == null ? 'Adicionar foto de perfil *' : 'Alterar foto',
              style: TextStyle(
                fontSize: 12,
                color: photo == null ? Colors.red.shade400 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Foto de perfil',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _photoOption(
              context,
              icon: Icons.camera_alt_outlined,
              label: 'Tirar foto',
              onTap: () {
                Navigator.pop(context);
                controller.pickPhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            _photoOption(
              context,
              icon: Icons.photo_library_outlined,
              label: 'Escolher da galeria',
              onTap: () {
                Navigator.pop(context);
                controller.pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, Color primaryColor) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: controller.isLoading.value
                ? null
                : () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    _formKey.currentState?.save();
                    controller.submit();
                  },
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Cadastrar como motorista',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ));
  }
}
