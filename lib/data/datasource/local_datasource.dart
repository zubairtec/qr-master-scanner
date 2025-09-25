import 'dart:convert';
import 'package:qr_master_scanner/core/app_pallete.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<List<Map<String, dynamic>>> getScanHistory();
  Future<List<Map<String, dynamic>>> getFavorites();
  Future<void> saveScanResult(Map<String, dynamic> result);
  Future<void> deleteScanHistory();
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> deleteScanResult(String id);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Map<String, dynamic>>> getScanHistory() async {
    final jsonString =
        sharedPreferences.getString(AppConstants.scanHistoryKey) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final history = await getScanHistory();
    return history.where((item) => item['isFavorite'] == true).toList();
  }

  @override
  Future<void> saveScanResult(Map<String, dynamic> result) async {
    final history = await getScanHistory();
    history.insert(0, result);
    await sharedPreferences.setString(
      AppConstants.scanHistoryKey,
      json.encode(history),
    );
  }

  @override
  Future<void> deleteScanHistory() async {
    await sharedPreferences.remove(AppConstants.scanHistoryKey);
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final history = await getScanHistory();
    final index = history.indexWhere((item) => item['id'] == id);

    if (index != -1) {
      history[index]['isFavorite'] = isFavorite;
      await sharedPreferences.setString(
        AppConstants.scanHistoryKey,
        json.encode(history),
      );
    }
  }

  @override
  Future<void> deleteScanResult(String id) async {
    final history = await getScanHistory();
    history.removeWhere((item) => item['id'] == id);
    await sharedPreferences.setString(
      AppConstants.scanHistoryKey,
      json.encode(history),
    );
  }
}
