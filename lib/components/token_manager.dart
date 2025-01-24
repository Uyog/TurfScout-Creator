import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TokenManager._internal();

  static TokenManager get instance => _instance;

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  Future<String?> retrieveToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'authToken');
  }
}
