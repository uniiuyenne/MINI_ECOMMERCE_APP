import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _auth?.currentUser;
  bool get isLoggedIn => user != null;

  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return _firebaseAuth ??= FirebaseAuth.instance;
  }

  Future<bool> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    final options = DefaultFirebaseOptions.maybeCurrentPlatform;
    if (options == null) {
      _error =
          'Firebase chưa có cấu hình cho nền tảng hiện tại. Hãy kiểm tra lib/firebase_options.dart.';
      notifyListeners();
      return false;
    }

    try {
      await Firebase.initializeApp(options: options);
      return true;
    } on FirebaseException catch (exception) {
      _error =
          'Không khởi tạo được Firebase: ${exception.message ?? exception.code}';
      notifyListeners();
      return false;
    } catch (exception) {
      _error = 'Không khởi tạo được Firebase: $exception';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final initialized = await _ensureFirebaseInitialized();
      if (!initialized) {
        return false;
      }

      final auth = _auth;
      if (auth == null) {
        _error = 'Không thể khởi tạo Firebase Auth.';
        notifyListeners();
        return false;
      }

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        await auth.signInWithPopup(provider);
        notifyListeners();
        return true;
      }

      if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
        _error = 'Nền tảng hiện tại chưa hỗ trợ Google Sign-In trực tiếp.';
        notifyListeners();
        return false;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _error = 'Bạn đã hủy đăng nhập.';
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (exception) {
      _error = 'Đăng nhập thất bại: ${exception.message ?? exception.code}';
      notifyListeners();
      return false;
    } catch (exception) {
      _error = 'Có lỗi xảy ra khi đăng nhập Google: $exception';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      final auth = _auth;
      if (auth == null) {
        _error = 'Firebase chưa được cấu hình.';
        notifyListeners();
        return;
      }

      await auth.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      notifyListeners();
    } catch (_) {
      _error = 'Đăng xuất thất bại.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
