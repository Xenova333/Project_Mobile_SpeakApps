import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../api_services.dart';
import 'account_page.dart';
import 'theme_page.dart';
import 'news_page.dart';
import 'add_event_page.dart';
import 'widgets/custom_bottom_nav.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showResetPasswordDialog(BuildContext context) async {
    final nimController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool obscurePass = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password Mahasiswa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM Mahasiswa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final nim = nimController.text.trim();
                          final newPassword = passwordController.text.trim();

                          if (nim.isEmpty || newPassword.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'NIM dan Password Baru tidak boleh kosong',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            final response = await http.post(
                              Uri.parse('${ApiConfig.baseUrl}/admin/reset-password'),
                              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                              body: {
                                'nim': nim,
                                'new_password': newPassword,
                              },
                            );
                            
                            final result = json.decode(response.body);
                            if (response.statusCode == 200 && result['status'] == 200) {
                              Get.snackbar(
                                'Sukses',
                                result['message'] ?? 'Password berhasil direset',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                              Navigator.pop(context);
                            } else {
                              Get.snackbar(
                                'Error',
                                result['message'] ?? 'Gagal mereset password',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Terjadi kesalahan: $e',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Terapkan Reset'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1128) : null,
                    gradient: isDark ? null : LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        primaryOrange.withOpacity(0.4),
                        primaryOrange.withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, size: 24, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Setelan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildSettingItem('Akun', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountPage()),
                          );
                        }),
                        const SizedBox(height: 16),
                        _buildSettingItem('Tema', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThemePage()),
                          );
                        }),
                        FutureBuilder<SharedPreferences>(
                          future: SharedPreferences.getInstance(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final role = snapshot.data!.getString('user_role');
                              if (role == 'admin') {
                                return Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildSettingItem(
                                      'Kelola Event',
                                      icon: Icons.event,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const NewsPage()),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSettingItem(
                                      'Tambah Event Baru',
                                      icon: Icons.add_circle_outline,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const AddEventPage()),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSettingItem(
                                      'Reset Password Mahasiswa',
                                      icon: Icons.security,
                                      onTap: () => _showResetPasswordDialog(context),
                                    ),
                                  ],
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Navigation Bar
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
