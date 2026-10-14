class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    this.attributes = const {},
  });

  final String id;
  final String code;
  final String name;
  final bool isActive;
  final Map<String, String> attributes;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    final rawAttributes =
        json['attributes'] as Map<String, dynamic>? ?? const {};

    return CatalogItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
      attributes: rawAttributes.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
