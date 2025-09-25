import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';

class ToggleFavorite {
  final ScanRepository repository;

  ToggleFavorite(this.repository);

  Future<void> call(String id, bool isFavorite) async {
    return await repository.toggleFavorite(id, isFavorite);
  }
}
