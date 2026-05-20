import 'dart:io';

import 'package:flutter/foundation.dart';

import 'auth_api.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

enum SessionStatus { loading, authenticated, unauthenticated }

class SessionController extends ChangeNotifier {
  SessionController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  SessionStatus _status = SessionStatus.loading;
  AuthTokens? _tokens;
  UserProfile? _profile;
  bool _isBusy = false;

  SessionStatus get status => _status;
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  bool get isLoading => _status == SessionStatus.loading;
  bool get isBusy => _isBusy;
  AuthTokens? get tokens => _tokens;
  UserProfile? get profile => _profile;

  Future<void> load() async {
    _status = SessionStatus.loading;
    notifyListeners();

    _tokens = await _authRepository.readTokens();
    if (_tokens == null) {
      _profile = null;
      _status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    if (_tokens!.isExpired) {
      final refreshed = await _tryRefreshTokens();
      if (refreshed == null) {
        await _authRepository.clear();
        _tokens = null;
        _profile = null;
        _status = SessionStatus.unauthenticated;
        notifyListeners();
        return;
      }
    }

    await _loadProfile();
  }

  Future<void> login({required String email, required String password}) async {
    if (_isBusy) {
      return;
    }
    _setBusy(true);
    try {
      await _authRepository.login(email: email, password: password);
      _tokens = await _authRepository.readTokens();
      _status = _tokens == null
          ? SessionStatus.unauthenticated
          : SessionStatus.authenticated;
      await _loadProfile();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> loginWithGoogle({required String idToken}) async {
    if (_isBusy) {
      return;
    }
    _setBusy(true);
    try {
      await _authRepository.loginWithGoogle(idToken: idToken);
      _tokens = await _authRepository.readTokens();
      _status = _tokens == null
          ? SessionStatus.unauthenticated
          : SessionStatus.authenticated;
      await _loadProfile();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    if (_isBusy) {
      return;
    }
    _setBusy(true);
    try {
      await _authRepository.register(
        email: email,
        username: username,
        password: password,
      );
      _tokens = await _authRepository.readTokens();
      _status = _tokens == null
          ? SessionStatus.unauthenticated
          : SessionStatus.authenticated;
      await _loadProfile();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_isBusy) {
      return;
    }
    _setBusy(true);
    try {
      await _changePasswordWithRefresh(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateProfile({required UpdateProfileRequest request}) async {
    if (_isBusy) {
      return;
    }
    _setBusy(true);
    try {
      _profile = await _updateProfileWithRefresh(request: request);
      _status = SessionStatus.authenticated;
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> requestOrganizerVerification() async {
    if (_isBusy || !isAuthenticated) {
      return;
    }
    _setBusy(true);
    try {
      _profile = await _authRepository.submitOrganizerVerification();
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshProfile() async {
    if (!isAuthenticated) {
      return;
    }
    await _loadProfile();
  }

  Future<void> logout() async {
    if (_isBusy) {
      return;
    }
    _setBusy(true);
    try {
      await _authRepository.logout();
    } finally {
      _tokens = null;
      _profile = null;
      _status = SessionStatus.unauthenticated;
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await _fetchProfileWithRefresh();
      _status = SessionStatus.authenticated;
      notifyListeners();
    } on AuthApiException catch (error) {
      debugPrint(
        'Auth: profile fetch failed (api) ${error.statusCode}: ${error.message}',
      );
      if (error.statusCode == 401) {
        await _authRepository.clear();
        _tokens = null;
        _profile = null;
        _status = SessionStatus.unauthenticated;
      } else {
        _status = SessionStatus.authenticated;
      }
      notifyListeners();
    } on AuthRepositoryException catch (error) {
      debugPrint('Auth: profile fetch failed (repo): ${error.message}');
      _status = SessionStatus.authenticated;
      notifyListeners();
    } on SocketException {
      debugPrint('Auth: profile fetch failed (network)');
      _status = SessionStatus.authenticated;
      notifyListeners();
    } catch (error) {
      debugPrint('Auth: profile fetch failed (unknown): $error');
      _status = SessionStatus.authenticated;
      notifyListeners();
    }
  }

  Future<UserProfile> _fetchProfileWithRefresh() async {
    try {
      return await _authRepository.fetchProfile();
    } on AuthApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      final refreshed = await _tryRefreshTokens();
      if (refreshed == null) {
        rethrow;
      }
      return _authRepository.fetchProfile();
    } on AuthRepositoryException catch (error) {
      debugPrint('Auth: profile fetch failed (repo): ${error.message}');
      rethrow;
    } catch (error) {
      debugPrint('Auth: profile fetch failed (unknown): $error');
      rethrow;
    }
  }

  Future<UserProfile> _updateProfileWithRefresh({
    required UpdateProfileRequest request,
  }) async {
    try {
      return await _authRepository.updateProfile(request);
    } on AuthApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      final refreshed = await _tryRefreshTokens();
      if (refreshed == null) {
        rethrow;
      }
      return _authRepository.updateProfile(request);
    } on AuthRepositoryException catch (error) {
      debugPrint('Auth: update profile failed (repo): ${error.message}');
      rethrow;
    } catch (error) {
      debugPrint('Auth: update profile failed (unknown): $error');
      rethrow;
    }
  }

  Future<void> _changePasswordWithRefresh({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on AuthApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      final refreshed = await _tryRefreshTokens();
      if (refreshed == null) {
        rethrow;
      }
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on AuthRepositoryException catch (error) {
      debugPrint('Auth: change password failed (repo): ${error.message}');
      rethrow;
    } catch (error) {
      debugPrint('Auth: change password failed (unknown): $error');
      rethrow;
    }
  }

  Future<AuthTokens?> _tryRefreshTokens() async {
    final refreshed = await _authRepository.refresh();
    if (refreshed != null) {
      _tokens = refreshed;
      _status = SessionStatus.authenticated;
      notifyListeners();
    }
    return refreshed;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) {
      return;
    }
    _isBusy = value;
    notifyListeners();
  }
}
