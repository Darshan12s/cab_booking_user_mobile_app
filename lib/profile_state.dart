import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends ChangeNotifier {
  String name = '';
  String email = '';
  String mobile = '+919087654321';
  String? profileImagePath;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('profile_name') ?? '';
    email = prefs.getString('profile_email') ?? '';
    mobile = prefs.getString('profile_mobile') ?? '+919087654321';
    profileImagePath = prefs.getString('profile_image_path');
  }

  Future<void> update({
    String? name,
    String? email,
    String? mobile,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      this.name = name;
      await prefs.setString('profile_name', name);
    }

    if (email != null) {
      this.email = email;
      await prefs.setString('profile_email', email);
    }

    if (mobile != null) {
      this.mobile = mobile;
      await prefs.setString('profile_mobile', mobile);
    }

    if (profileImagePath != null) {
      this.profileImagePath = profileImagePath;
      await prefs.setString('profile_image_path', profileImagePath);
    }

    notifyListeners();
  }
}

final userProfile = UserProfile();
