import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/user.dart';
import 'package:if_ride/services/auth_service.dart';
import 'package:if_ride/utils/cities.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:if_ride/utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  late final TextEditingController _nameController;
  String? _selectedCity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedCity = user?.city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(
        name: _nameController.text.trim(),
        city: _selectedCity,
      );
      // Atualiza o usuário localmente sem re-login
      final u = _authController.currentUser.value;
      if (u != null) {
        final updated = User(
          id: u.id,
          name: _nameController.text.trim(),
          email: u.email,
          role: u.role,
          imageUrl: u.imageUrl,
          city: _selectedCity,
        );
        _authController.currentUser.value = updated;
        await _storage.write(key: userNameKey, value: updated.name);
      }
      Get.back();
      Get.snackbar(
        'Perfil atualizado',
        'Seus dados foram salvos.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erro ao salvar',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alterar dados pessoais',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: primaryColor),
                  )
                : Text('Salvar',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.person, size: 48, color: primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('Nome completo',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Seu nome',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe seu nome.' : null,
              ),
              const SizedBox(height: 24),

              const Text('Cidade',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    hint: const Text('Selecione uma cidade',
                        style: TextStyle(color: Colors.black45)),
                    borderRadius: BorderRadius.circular(12),
                    items: cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCity = v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A cidade é usada para melhorar as sugestões de carona.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Salvar alterações',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
