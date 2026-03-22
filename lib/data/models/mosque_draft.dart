class MosqueDraft {
  const MosqueDraft({
    this.id,
    required this.name,
    this.area,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
    this.isActive = true,
    this.notes,
  });

  final int? id;
  final String name;
  final String? area;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final bool isActive;
  final String? notes;
}
