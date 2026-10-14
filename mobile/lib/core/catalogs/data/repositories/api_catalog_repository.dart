import 'package:dio/dio.dart';

import '../../../network/api_client.dart';
import '../../../network/api_exception.dart';
import '../../domain/entities/catalog_bundle.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<CatalogBundle> loadCatalogs() async {
    try {
      final responses = await Future.wait([
        _apiClient.dio.get<List<dynamic>>('/api/catalogos/tipos-vehiculo'),
        _apiClient.dio.get<List<dynamic>>('/api/catalogos/tipos-mantenimiento'),
        _apiClient.dio.get<List<dynamic>>('/api/catalogos/tipos-documento'),
        _apiClient.dio.get<List<dynamic>>('/api/catalogos/categorias-gasto'),
      ]);

      return CatalogBundle(
        vehicleTypes: _simpleItems(responses[0].data),
        maintenanceTypes: _maintenanceItems(responses[1].data),
        documentTypes: _simpleItems(responses[2].data),
        expenseCategories: _simpleItems(responses[3].data),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  List<CatalogItem> _simpleItems(List<dynamic>? raw) {
    return (raw ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CatalogItem(
            id: item['id'].toString(),
            code: item['id'].toString(),
            name: item['nombre']?.toString() ?? '',
            isActive: true,
          ),
        )
        .toList();
  }

  List<CatalogItem> _maintenanceItems(List<dynamic>? raw) {
    return (raw ?? const []).whereType<Map<String, dynamic>>().map((item) {
      final category = item['categoria']?.toString().trim().toUpperCase();

      return CatalogItem(
        id: item['id'].toString(),
        code: item['id'].toString(),
        name: item['nombre']?.toString() ?? '',
        isActive: true,
        attributes: {
          'category': category == 'CORRECTIVO' ? 'corrective' : 'preventive',
        },
      );
    }).toList();
  }
}
