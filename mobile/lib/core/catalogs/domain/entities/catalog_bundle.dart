import 'catalog_item.dart';

class CatalogBundle {
  const CatalogBundle({
    required this.vehicleTypes,
    required this.maintenanceTypes,
    required this.documentTypes,
    required this.expenseCategories,
  });

  final List<CatalogItem> vehicleTypes;
  final List<CatalogItem> maintenanceTypes;
  final List<CatalogItem> documentTypes;
  final List<CatalogItem> expenseCategories;

  List<CatalogItem> get activeVehicleTypes {
    return vehicleTypes.where((item) => item.isActive).toList();
  }

  List<CatalogItem> get activeMaintenanceTypes {
    return maintenanceTypes.where((item) => item.isActive).toList();
  }

  List<CatalogItem> get activeDocumentTypes {
    return documentTypes.where((item) => item.isActive).toList();
  }

  List<CatalogItem> get activeExpenseCategories {
    return expenseCategories.where((item) => item.isActive).toList();
  }

  CatalogItem? vehicleTypeById(String id) {
    return _findById(vehicleTypes, id);
  }

  CatalogItem? maintenanceTypeById(String id) {
    return _findById(maintenanceTypes, id);
  }

  CatalogItem? documentTypeById(String id) {
    return _findById(documentTypes, id);
  }

  CatalogItem? expenseCategoryById(String id) {
    return _findById(expenseCategories, id);
  }

  CatalogItem? _findById(List<CatalogItem> items, String id) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }
}
