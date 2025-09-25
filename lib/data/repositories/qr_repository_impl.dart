import 'dart:convert';
import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRepositoryImpl implements ScanRepository {
  static const String _scanHistoryKey = 'scan_history';

  @override
  Future<List<ScanResult>> getScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_scanHistoryKey);

      if (historyJson == null) {
        return [];
      }

      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.map((item) => ScanResult.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to get scan history: $e');
    }
  }

  @override
  Future<void> saveScanResult(ScanResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<ScanResult> currentHistory = await getScanHistory();

      currentHistory.removeWhere((item) => item.id == result.id);

      currentHistory.insert(0, result);

      final String historyJson = json.encode(
        currentHistory.map((item) => item.toMap()).toList(),
      );
      await prefs.setString(_scanHistoryKey, historyJson);
    } catch (e) {
      throw Exception('Failed to save scan result: $e');
    }
  }

  @override
  Future<void> deleteScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scanHistoryKey);
    } catch (e) {
      throw Exception('Failed to delete scan history: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<ScanResult> currentHistory = await getScanHistory();

      final int index = currentHistory.indexWhere((item) => item.id == id);
      if (index != -1) {
        currentHistory[index] = currentHistory[index].copyWith(
          isFavorite: isFavorite,
        );

        final String historyJson = json.encode(
          currentHistory.map((item) => item.toMap()).toList(),
        );
        await prefs.setString(_scanHistoryKey, historyJson);
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<void> deleteScanResult(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<ScanResult> currentHistory = await getScanHistory();
      currentHistory.removeWhere((item) => item.id == id);
      final String historyJson = json.encode(
        currentHistory.map((item) => item.toMap()).toList(),
      );
      await prefs.setString(_scanHistoryKey, historyJson);
    } catch (e) {
      throw Exception('Failed to delete scan result: $e');
    }
  }

  @override
  Future<List<ScanResult>> getFavorites() async {
    try {
      final List<ScanResult> currentHistory = await getScanHistory();
      return currentHistory.where((item) => item.isFavorite == true).toList();
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }
}
