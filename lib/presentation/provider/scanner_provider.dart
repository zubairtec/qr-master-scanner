import 'package:flutter/foundation.dart';
import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/domain/usecases/delete_scan_history.dart';
import 'package:qr_master_scanner/domain/usecases/get_scan_history.dart';
import 'package:qr_master_scanner/domain/usecases/save_scan_result.dart';
import 'package:qr_master_scanner/domain/usecases/toggle_favorite.dart';

class ScanProvider with ChangeNotifier {
  final GetScanHistory getScanHistory;
  final SaveScanResult saveScanResult;
  final DeleteScanHistory deleteScanHistory;
  final ToggleFavorite toggleFavorite;
  List<ScanResult> _scanHistory = [];
  List<ScanResult> _favorites = [];
  bool _isLoading = false;
  String? _error;
  List<ScanResult> get scanHistory => _scanHistory;
  List<ScanResult> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ScanProvider({
    required this.getScanHistory,
    required this.saveScanResult,
    required this.deleteScanHistory,
    required this.toggleFavorite,
  });
  Future<void> loadScanHistory() async {
    _setLoading(true);
    _error = null;
    try {
      final history = await getScanHistory.call();
      _scanHistory = history;
      _updateFavoritesList();
    } catch (e) {
      _error = 'Failed to load scan history: $e';
      _scanHistory = [];
      _favorites = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addScanResult(ScanResult result) async {
    _error = null;
    try {
      await saveScanResult.call(result);
      _scanHistory.insert(0, result);
      _updateFavoritesList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save scan result: $e';
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _error = null;
    try {
      await deleteScanHistory.call();
      _scanHistory.clear();
      _favorites.clear();
      _updateFavoritesList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear history: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatus(String id) async {
    _error = null;
    try {
      final index = _scanHistory.indexWhere((item) => item.id == id);
      if (index == -1) {
        throw Exception('Item not found');
      }
      final currentStatus = _scanHistory[index].isFavorite;
      final newStatus = !currentStatus;
      _scanHistory[index] = _scanHistory[index].copyWith(isFavorite: newStatus);
      _updateFavoritesList();
      await toggleFavorite.call(id, newStatus);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update favorite status: $e';
      notifyListeners();
    }
  }

  void _updateFavoritesList() {
    _favorites = _scanHistory.where((item) => item.isFavorite).toList();
    _favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
