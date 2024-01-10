import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String _prefix = "APP_USER_";

  static String KeyIdUser = "${_prefix}USERKEY";
  static String KeyUserName = "${_prefix}USERNAMEKEY";
  static String KeyEmailUser = "${_prefix}USEREMAILKEY";
  static String KeyUserProfile = "${_prefix}USERPROFILEKEY";
  static String userWalletKey = "${_prefix}USERWALLETKEY";

  Future<void> clearAllPreferences() async {
    print('Clearing preferences...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Preferences cleared.');
  }

  Future<bool> saveUserUId(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(KeyIdUser, uid);
  }

  Future<bool> saveUserProfile(String getProfileUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(KeyUserProfile, getProfileUser);
  }

  Future<bool> saveUserName(String getNameUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(KeyUserName, getNameUser);
  }

  Future<bool> saveUserEmail(String getEmailUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(KeyEmailUser, getEmailUser);
  }

  Future<bool> saveUserWallet(String getWalletUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userWalletKey, getWalletUser);
  }

  Future<String?> getIdUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KeyIdUser);
  }

  Future<String?> getProfileUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KeyUserProfile);
  }

  Future<String?> getNameUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KeyUserName);
  }

  Future<String?> getEmailUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KeyEmailUser);
  }

  Future<String?> getWalletUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userWalletKey);
  }
}