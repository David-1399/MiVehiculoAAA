import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_catalog_repository.dart';
import '../../domain/entities/catalog_bundle.dart';
import '../../domain/repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return ApiCatalogRepository();
});

final catalogsProvider = FutureProvider<CatalogBundle>((ref) async {
  final repository = ref.read(catalogRepositoryProvider);

  return repository.loadCatalogs();
});
