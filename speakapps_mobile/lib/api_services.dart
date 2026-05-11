class ApiConfig {
  // Hanya digunakan sebagai tempat penyimpanan konfigurasi URL utama.
  // Tidak memuat logika pengambilan data apapun di sini.
  static const String baseUrl = 'http://10.176.165.212:8080/api';

  // Endpoint baru untuk mengambil daftar teman
  static String acceptedFriendsUrl(int myId) {
    return '$baseUrl/friends/accepted/$myId';
  }
}