import 'package:qr_master_scanner/domain/entities/scan_result.dart';

abstract class ScanRepository {
  Future<List<ScanResult>> getScanHistory();
  Future<List<ScanResult>> getFavorites();
  Future<void> saveScanResult(ScanResult result);
  Future<void> deleteScanHistory();
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> deleteScanResult(String id);
}
