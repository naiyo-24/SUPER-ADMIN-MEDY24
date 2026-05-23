import 'dart:convert';

class Medicine {
  final String medicineId;
  final String medicineName;
  final String medicineCategory;
  final String medicineQuantity;
  final double mrp;
  final double? discountPercent;
  final double finalSellingPrice;
  final String? medicineDescription;
  final String? medicineComposition;
  final List<dynamic> precautions;
  final String? prescriptionRequired;
  final String? medicinePhoto;

  Medicine({
    required this.medicineId,
    required this.medicineName,
    required this.medicineCategory,
    required this.medicineQuantity,
    required this.mrp,
    this.discountPercent,
    required this.finalSellingPrice,
    this.medicineDescription,
    this.medicineComposition,
    required this.precautions,
    this.prescriptionRequired,
    this.medicinePhoto,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static double _parseNonNullDouble(dynamic value, [double fallback = 0.0]) {
    return _parseDouble(value) ?? fallback;
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final mrp = _parseNonNullDouble(json['mrp']);
    final discount = _parseDouble(json['discount_percent']);
    final inferredFinal = discount == null
        ? mrp
        : mrp - (mrp * discount / 100);
    final finalPrice =
        _parseDouble(json['final_selling_price']) ?? inferredFinal;

    return Medicine(
      medicineId: json['medicine_id'] ?? '',
      medicineName: json['medicine_name'] ?? '',
      medicineCategory: json['medicine_category'] ?? '',
      medicineQuantity: json['medicine_quantity'] ?? '',
      mrp: mrp,
      discountPercent: discount,
      finalSellingPrice: finalPrice,
      medicineDescription: json['medicine_description'],
      medicineComposition: json['medicine_composition'],
      precautions: json['precautions'] is String
          ? jsonDecode(json['precautions'])
          : (json['precautions'] ?? []),
      prescriptionRequired: json['prescription_required'],
      medicinePhoto: json['medicine_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'medicine_category': medicineCategory,
      'medicine_quantity': medicineQuantity,
      'mrp': mrp,
      'discount_percent': discountPercent,
      'final_selling_price': finalSellingPrice,
      'medicine_description': medicineDescription,
      'medicine_composition': medicineComposition,
      'precautions': precautions,
      'prescription_required': prescriptionRequired,
      'medicine_photo': medicinePhoto,
    };
  }
}
