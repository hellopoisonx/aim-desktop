import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<String?> readUserId();
  Future<String?> readDeviceId();
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  });
  Future<void> clearSession();
}

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'aim.access_token';
  static const _refreshTokenKey = 'aim.refresh_token';
  static const _userIdKey = 'aim.user_id';
  static const _deviceIdKey = 'aim.device_id';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<String?> readUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<String?> readDeviceId() async {
    try {
      return await _storage.read(key: _deviceIdKey);
    } on MissingPluginException {
      return null;
    }
  }


  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _deviceIdKey, value: deviceId);
    } on MissingPluginException {
      // No-op in environments without secure storage plugin
    }
  }


  @override
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _deviceIdKey);
    } on MissingPluginException {
      // No-op in environments without secure storage plugin
    }
  }
}
