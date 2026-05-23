import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../models/medicine.dart';
import '../services/medicine_services.dart';

class MedicineState {
  final bool isLoading;
  final String? error;
  final List<Medicine> medicines;
  final int total;
  final int currentPage;
  final int limit;
  final String? searchQuery;
  final String? category;
  final String? priceRange;

  MedicineState({
    this.isLoading = false,
    this.error,
    this.medicines = const [],
    this.total = 0,
    this.currentPage = 1,
    this.limit = 20,
    this.searchQuery,
    this.category,
    this.priceRange,
  });

  MedicineState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Medicine>? medicines,
    int? total,
    int? currentPage,
    int? limit,
    String? searchQuery,
    String? category,
    String? priceRange,
  }) {
    return MedicineState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      medicines: medicines ?? this.medicines,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
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

      Map<String, dynamic> result;
      if ((state.searchQuery != null && state.searchQuery!.isNotEmpty) ||
          (state.category != null && state.category != 'All') ||
          (state.priceRange != null && state.priceRange != 'All')) {
        List<String>? priceRanges;
        if (state.priceRange != null && state.priceRange != 'All') {
          if (state.priceRange == 'Under 100') {
            priceRanges = ['0-100'];
          } else if (state.priceRange == '100-500') {
            priceRanges = ['100-500'];
          } else if (state.priceRange == '500-1000') {
            priceRanges = ['500-1000'];
          } else if (state.priceRange == '1000-5000') {
            priceRanges = ['1000-5000'];
          } else if (state.priceRange == 'Above 5000') {
            priceRanges = ['5000+'];
          }
        }

        result = await _services.searchMedicines(
          searchTerm: state.searchQuery,
          category: state.category == 'All' ? null : state.category,
          priceRange: priceRanges,
          page: p,
          limit: l,
        );
      } else {
        result = await _services.getAllMedicines(page: p, limit: l);
      }

      state = state.copyWith(
        isLoading: false,
        medicines: result['medicines'],
        total: result['total'],
        currentPage: result['page'],
        limit: result['limit'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void filterMedicines({String? query, String? category, String? priceRange}) {
    state = state.copyWith(
      searchQuery: query,
      category: category,
      priceRange: priceRange,
      currentPage: 1, // reset to page 1 on new search
    );
    fetchMedicines(page: 1);
  }

  Future<Map<String, dynamic>?> uploadCsv(
    Uint8List fileBytes,
    String fileName,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final initialResult = await _services.uploadMedicinesCsv(
        fileBytes,
        fileName,
      );
      final jobId = initialResult['job_id'];

      if (jobId == null) {
        throw Exception("No job ID returned from server.");
      }

      // Poll for status
      while (true) {
        await Future.delayed(const Duration(seconds: 2));
        final statusResult = await _services.checkImportStatus(jobId);
        final status = statusResult['status'];

        if (status == 'completed') {
          await fetchMedicines(page: 1); // Refresh list
          return statusResult['results'];
        } else if (status == 'failed') {
          throw Exception(statusResult['error'] ?? 'Import failed');
        }
        // If status is 'queued' or 'processing', continue polling
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
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
    String? prescriptionRequired,
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
        prescriptionRequired: prescriptionRequired,
        photoBytes: photoBytes,
        photoFileName: photoFileName,
      );
      await fetchMedicines(page: 1); // Refresh list
      return newMedicine;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
    String? prescriptionRequired,
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
        prescriptionRequired: prescriptionRequired,
        photoBytes: photoBytes,
        photoFileName: photoFileName,
      );
      await fetchMedicines(page: state.currentPage); // Refresh list
      return updatedMedicine;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
