import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

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
                        'Profile',
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
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // Circle Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/rimuru.jpg',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Edit Foto Profile Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Edit foto profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Info Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: primaryOrange),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? primaryOrange.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                                  blurRadius: isDark ? 20 : 10,
                                  spreadRadius: isDark ? 2 : 0,
                                  offset: isDark ? Offset.zero : const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildEditField('Nama', 'Ifant Ristanto', primaryOrange),

                                _buildEditField('Nim', '240302024', primaryOrange),

                                _buildEditField('Semester', '4', primaryOrange),

                                _buildEditField('Jenis Kelamin', 'Laki - Laki', primaryOrange),
                                
                                const SizedBox(height: 30),
                                
                                // Simpan Perubahan Button
                                GestureDetector(
                                  onTap: () {
                                    // Save logic would go here, then go back
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: primaryOrange,
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Simpan Perubahan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildEditField(String label, String value, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5ED), // Light beige
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }


}
