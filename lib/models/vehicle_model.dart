class Vehicle {
  final int? id;
  final String vehicleNumber;
  final String imagePath;
  final DateTime scannedAt;

  Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.imagePath,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vehicle_number': vehicleNumber,
      'image_path': imagePath,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      vehicleNumber: map['vehicle_number'] as String,
      imagePath: map['image_path'] as String,
      scannedAt: DateTime.parse(map['scanned_at'] as String),
    );
  }
}
