import '../entities/catalog_bundle.dart';

abstract interface class CatalogRepository {
  Future<CatalogBundle> loadCatalogs();
}
