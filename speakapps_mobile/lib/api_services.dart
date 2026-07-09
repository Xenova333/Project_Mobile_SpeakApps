class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';

  // Endpoint baru untuk mengambil daftar teman
  static String acceptedFriendsUrl(int myId) {
    return '$baseUrl/friends/accepted/$myId';
  }
}