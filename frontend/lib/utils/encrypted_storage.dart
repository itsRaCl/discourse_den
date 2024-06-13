import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedStorage{
	final _storage = const FlutterSecureStorage();

Future<(void, Exception?)> set({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(key: key, value: value);
      return (null, null);
    } catch (e) {
      return (null, e as Exception);
    }
  }

  Future<(String?, Exception?)> get({required String key}) async {
    try {
      return (await _storage.read(key: key), null);
    } catch (e) {
      return (null, e as Exception);
    }
  }

  Future<(void, Exception?)> deleteAll() async {
    try {
      await _storage.deleteAll();
      return (null, null);
    } catch (e) {
      return (null, e as Exception);
    }
  }
}
