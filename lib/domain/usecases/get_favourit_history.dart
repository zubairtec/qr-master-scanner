import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';

class GetFavorites {
  final ScanRepository repository;

  GetFavorites(this.repository);

  Future<List<ScanResult>> call() async {
    return await repository.getFavorites();
  }
}
