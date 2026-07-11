import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser {
  final String role;
  CurrentUser({required this.role});
}

class AuthController extends GetxController {
  var currentUser = CurrentUser(role: 'user').obs;

  @override
  void onInit() {
    super.onInit();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    currentUser.value = CurrentUser(role: role);
  }
}
