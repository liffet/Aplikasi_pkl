  import 'package:flutter/material.dart';
  import '../models/user_model.dart';
  import '../services/auth_service.dart';

  class EditProfilePage extends StatefulWidget {
    final UserModel user;
    const EditProfilePage({super.key, required this.user});

    @override
    State<EditProfilePage> createState() => _EditProfilePageState();
  }

  class _EditProfilePageState extends State<EditProfilePage> {
    final _formKey = GlobalKey<FormState>();
    late TextEditingController _nameController;
    late TextEditingController _emailController;

    bool _isLoading = false;
    final AuthService _authService = AuthService();

    @override
    void initState() {
      super.initState();
      _nameController = TextEditingController(text: widget.user.name);
      _emailController = TextEditingController(text: widget.user.email);
    }

    @override
    void dispose() {
      _nameController.dispose();
      _emailController.dispose();
      super.dispose();
    }

    Future<void> _saveProfile() async {
      if (!_formKey.currentState!.validate()) return;

      setState(() => _isLoading = true);

      try {
        final updatedUser = await _authService.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
          token: widget.user.token,
        );

        setState(() => _isLoading = false);

        if (updatedUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );

          Navigator.pop(context, updatedUser);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui profil')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profil'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Input Nama
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                // Input Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Email tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 24),
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
