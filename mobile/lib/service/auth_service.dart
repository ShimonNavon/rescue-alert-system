// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService extends ChangeNotifier {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   static const _tokenKey = 'auth_token';

//   bool _isLoggedIn = false;
//   bool _isLoading = true;
//   String? _token;

//   bool get isLoggedIn => _isLoggedIn;
//   bool get isLoading => _isLoading;
//   String? get token => _token;

//   AuthService() {
//     _init();
//   }

//   // 🔹 Initialize (called once on app start)
//   Future<void> _init() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _token = await _storage.read(key: _tokenKey);

//       if (_token != null && _token!.isNotEmpty) {
//         _isLoggedIn = true;
//       } else {
//         _isLoggedIn = false;
//       }
//     } catch (e) {
//       _isLoggedIn = false;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   // 🔹 Login (replace with real API)
//   Future<void> login(String username, String password) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // TODO: call your backend / Cognito / API
//       await Future.delayed(const Duration(seconds: 1));

//       // fake token (replace with real)
//       _token = "mock_token_${DateTime.now().millisecondsSinceEpoch}";

//       await _storage.write(key: _tokenKey, value: _token);

//       _isLoggedIn = true;
//     } catch (e) {
//       _isLoggedIn = false;
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // 🔹 Logout
//   Future<void> logout() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _storage.delete(key: _tokenKey);

//       _token = null;
//       _isLoggedIn = false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // 🔹 Optional: refresh token
//   Future<void> refreshToken() async {
//     if (_token == null) return;

//     try {
//       // TODO: call refresh endpoint
//       await Future.delayed(const Duration(milliseconds: 500));

//       _token = "refreshed_${DateTime.now().millisecondsSinceEpoch}";
//       await _storage.write(key: _tokenKey, value: _token);

//       notifyListeners();
//     } catch (_) {
//       await logout();
//     }
//   }
// }
