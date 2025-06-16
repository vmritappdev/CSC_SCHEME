import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;

  bool get isLoggedIn => _isLoggedIn;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get phoneNumber => _phoneNumber;

  Future<void> signUp(String firstName, String lastName, String phoneNumber) async {
    // Here you can add your sign-up logic, like API calls

    // Save user data in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userFirstName', firstName);
    await prefs.setString('userLastName', lastName);
    await prefs.setString('userPhoneNumber', phoneNumber);

    // Update local state
    _isLoggedIn = true;
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;

    notifyListeners();
  }

  Future<void> signIn(String phoneNumber) async {
    // Here you can add your sign-in logic, like API calls

    // For demonstration, assume successful login
    _isLoggedIn = true;
    _phoneNumber = phoneNumber; // Retrieve other user data if needed
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userFirstName');
    await prefs.remove('userLastName');
    await prefs.remove('userPhoneNumber');

    _isLoggedIn = false;
    _firstName = null;
    _lastName = null;
    _phoneNumber = null;

    notifyListeners();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _firstName = prefs.getString('userFirstName');
    _lastName = prefs.getString('userLastName');
    _phoneNumber = prefs.getString('userPhoneNumber');

    notifyListeners();
  }
}
