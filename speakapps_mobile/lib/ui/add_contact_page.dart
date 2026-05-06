import 'package:flutter/material.dart';

class AddContactPage extends StatelessWidget {
  const AddContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
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
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ]
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, size: 24, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Tambah Kontak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Add Contact Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tambah Teman',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'NIM :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Input Field
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3EB), // Very light orange/beige
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Masukkan Nama teman',
                          hintStyle: TextStyle(color: Colors.black54, fontSize: 10),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 14.0), // Center the text vertically
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Submit Button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Simulate successful request
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
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
                            'Kirim Permintaan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
