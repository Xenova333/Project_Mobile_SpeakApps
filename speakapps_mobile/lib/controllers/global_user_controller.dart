import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalUserController extends GetxController {
  // Observables untuk memicu update UI secara real-time
  var userPic = ''.obs;
  var imageTimestamp = DateTime.now().millisecondsSinceEpoch.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserPic();
  }

  /// Memuat foto profil saat aplikasi atau state diinisialisasi
  Future<void> loadUserPic() async {
    final prefs = await SharedPreferences.getInstance();
    userPic.value = prefs.getString('user_pic') ?? '';
    // Buat timestamp awal agar cache busting siap
    imageTimestamp.value = DateTime.now().millisecondsSinceEpoch;
  }

  /// Memperbarui foto profil baru setelah sukses upload ke server CI4
  Future<void> updateUserPic(String newPic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pic', newPic);
    
    // Update State Global (memicu Obx di seluruh aplikasi)
    userPic.value = newPic;
    
    // Update timestamp agar Image.network melakukan cache busting
    imageTimestamp.value = DateTime.now().millisecondsSinceEpoch;
  }
}
