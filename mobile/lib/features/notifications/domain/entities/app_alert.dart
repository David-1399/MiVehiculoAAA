class AppAlert {
  const AppAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.vehicle,
    required this.level,
    this.distanceKm,
  });

  final String id;
  final String title;
  final String description;
  final String vehicle;
  final String level;
  final int? distanceKm;
}
