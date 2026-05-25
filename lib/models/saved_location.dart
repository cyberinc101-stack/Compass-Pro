class SavedLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final DateTime savedAt;  // ADDED: This field for sorting
  final String? notes;
  final String? category;
  final String? address;
  final double? altitude;
  final double? accuracy;

  SavedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    DateTime? savedAt,  // ADDED: Optional parameter
    this.notes,
    this.category,
    this.address,
    this.altitude,
    this.accuracy,
  }) : savedAt = savedAt ?? DateTime.now();  // ADDED: Default to now if not provided

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'savedAt': savedAt.toIso8601String(),  // ADDED: Include in JSON
      'notes': notes,
      'category': category,
      'address': address,
      'altitude': altitude,
      'accuracy': accuracy,
    };
  }

  // Create from JSON
  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      savedAt: json['savedAt'] != null   // ADDED: Parse savedAt from JSON
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),  // Fallback for old data
      notes: json['notes'] as String?,
      category: json['category'] as String?,
      address: json['address'] as String?,
      altitude: json['altitude'] as double?,
      accuracy: json['accuracy'] as double?,
    );
  }

  // Create a copy with updated fields
  SavedLocation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    DateTime? savedAt,  // ADDED: Allow updating savedAt
    String? notes,
    String? category,
    String? address,
    double? altitude,
    double? accuracy,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      savedAt: savedAt ?? this.savedAt,  // ADDED
      notes: notes ?? this.notes,
      category: category ?? this.category,
      address: address ?? this.address,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}