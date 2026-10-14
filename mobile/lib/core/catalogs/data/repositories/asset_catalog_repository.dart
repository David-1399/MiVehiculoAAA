import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/catalog_bundle.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';

class AssetCatalogRepository implements CatalogRepository {
  static const _assetPath = 'assets/catalogs/catalogs.seed.json';

  @override
  Future<CatalogBundle> loadCatalogs() async {
    final raw = await rootBundle.loadString(_assetPath);

    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    return CatalogBundle(
      vehicleTypes: _parse(decoded['vehicleTypes']),
      maintenanceTypes: _parse(decoded['maintenanceTypes']),
      documentTypes: _parse(decoded['documentTypes']),
      expenseCategories: _parse(decoded['expenseCategories']),
    );
  }

  List<CatalogItem> _parse(dynamic raw) {
    final list = raw as List<dynamic>? ?? const [];

    return list
        .map((item) => CatalogItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
