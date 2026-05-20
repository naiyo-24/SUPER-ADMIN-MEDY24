import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../models/medicine.dart';
import '../services/medicine_services.dart';

class MedicineState {
  final bool isLoading;
  final String? error;
  final List<Medicine> medicines;
  final List<Medicine> filteredMedicines;
  final int total;
  final int currentPage;
  final int limit;

  MedicineState({
    this.isLoading = false,
    this.error,
    this.medicines = const [],
    this.filteredMedicines = const [],
    this.total = 0,
    this.currentPage = 1,
    this.limit = 20,
  });

  MedicineState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Medicine>? medicines,
    List<Medicine>? filteredMedicines,
    int? total,
    int? currentPage,
    int? limit,
  }) {
    return MedicineState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      medicines: medicines ?? this.medicines,
      filteredMedicines: filteredMedicines ?? this.filteredMedicines,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
    );
  }
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  final MedicineServices _services;

  MedicineNotifier(this._services) : super(MedicineState()) {
    fetchMedicines();
  }

  Future<void> fetchMedicines({int? page, int? limit}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final p = page ?? state.currentPage;
      final l = limit ?? state.limit;
      final result = await _services.getAllMedicines(page: p, limit: l);
      state = state.copyWith(
        isLoading: false,
        medicines: result['medicines'],
        filteredMedicines: result['medicines'],
        total: result['total'],
        currentPage: result['page'],
        limit: result['limit'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filterMedicines({String? query, String? category, String? priceRange}) {
    var filtered = state.medicines;

    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((m) {
        return m.medicineName.toLowerCase().contains(lowerQuery) ||
               m.medicineId.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (category != null && category != 'All') {
      filtered = filtered.where((m) => m.medicineCategory == category).toList();
    }

    if (priceRange != null && priceRange != 'All') {
      filtered = filtered.where((m) {
        final price = m.finalSellingPrice;
        if (priceRange == 'Under 100') return price < 100;
        if (priceRange == '100-500') return price >= 100 && price <= 500;
        if (priceRange == 'Above 500') return price > 500;
        return true;
      }).toList();
    }

    state = state.copyWith(filteredMedicines: filtered);
  }

  Future<Medicine?> createMedicine({
    required String medicineName,
    required String medicineCategory,
    required String medicineQuantity,
    required double mrp,
    double? discountPercent,
    String? medicineDescription,
    String? medicineComposition,
    String? precautions,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newMedicine = await _services.createMedicine(
        medicineName: medicineName,
        medicineCategory: medicineCategory,
        medicineQuantity: medicineQuantity,
        mrp: mrp,
        discountPercent: discountPercent,
        medicineDescription: medicineDescription,
        medicineComposition: medicineComposition,
        precautions: precautions,
        photoBytes: photoBytes,
        photoFileName: photoFileName,
      );
      await fetchMedicines(page: 1); // Refresh list
      return newMedicine;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<Medicine?> updateMedicine({
    required String medicineId,
    String? medicineName,
    String? medicineCategory,
    String? medicineQuantity,
    double? mrp,
    double? discountPercent,
    String? medicineDescription,
    String? medicineComposition,
    String? precautions,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedMedicine = await _services.updateMedicine(
        medicineId: medicineId,
        medicineName: medicineName,
        medicineCategory: medicineCategory,
        medicineQuantity: medicineQuantity,
        mrp: mrp,
        discountPercent: discountPercent,
        medicineDescription: medicineDescription,
        medicineComposition: medicineComposition,
        precautions: precautions,
        photoBytes: photoBytes,
        photoFileName: photoFileName,
      );
      await fetchMedicines(page: state.currentPage); // Refresh list
      return updatedMedicine;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> deleteMedicines(List<String> medicineIds) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _services.deleteMedicines(medicineIds);
      await fetchMedicines(page: 1); // Refresh list
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}
