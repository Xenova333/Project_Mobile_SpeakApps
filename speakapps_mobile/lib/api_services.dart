class ApiConfig {
  // ⚠️  Ganti ke IP Wi-Fi laptop yang sedang aktif agar HP Android
  //    di jaringan yang sama bisa menjangkau server CI4.
  //    Jangan gunakan 'localhost' agar tidak gagal di perangkat Android.
  static const String baseUrl = 'http://localhost:8080/api';

  // Endpoint untuk mengambil daftar teman yang sudah accepted
  static String acceptedFriendsUrl(int myId) => '$baseUrl/friends/accepted/$myId';

  // Endpoint untuk mengambil permintaan pertemanan yang sudah dikirim (status pending)
  static String sentRequestsUrl(int myId) => '$baseUrl/friends/sent/$myId';

  // Endpoint untuk events
  static String get eventsUrl => '$baseUrl/events';
}