import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:typed_data';
import '../models/medicine.dart';
import 'api_url.dart';

class MedicineServices {
  late final Dio _dio;

  MedicineServices() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        connectTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  Future<Map<String, dynamic>> getAllMedicines({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiUrls.medicineGetAll,
        queryParameters: {'page': page, 'limit': limit},
      );

      final raw = response.data['data'] as List;
      final medicines = raw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Medicine.fromJson(map);
      }).toList();
      return {
        'total': response.data['total'],
        'page': response.data['page'],
        'limit': response.data['limit'],
        'medicines': medicines,
      };
    } catch (e) {
      throw Exception('Failed to fetch medicines: $e');
    }
  }

  Future<Medicine> getMedicineById(String medicineId) async {
    try {
      final response = await _dio.get('${ApiUrls.medicineGetById}/$medicineId');
      final map = Map<String, dynamic>.from(response.data as Map);
      return Medicine.fromJson(map);
    } catch (e) {
      throw Exception('Failed to fetch medicine details: $e');
    }
  }

  Future<Medicine> createMedicine({
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
    try {
      final formDataMap = <String, dynamic>{
        'medicine_name': medicineName,
        'medicine_category': medicineCategory,
        'medicine_quantity': medicineQuantity,
        'mrp': mrp.toString(),
      };

      if (discountPercent != null) {
        formDataMap['discount_percent'] = discountPercent.toString();
      }
      if (medicineDescription != null && medicineDescription.isNotEmpty) {
        formDataMap['medicine_description'] = medicineDescription;
      }
      if (medicineComposition != null && medicineComposition.isNotEmpty) {
        formDataMap['medicine_composition'] = medicineComposition;
      }
      if (precautions != null && precautions.isNotEmpty) {
        formDataMap['precautions'] = precautions;
      }
      if (prescriptionRequired != null) {
        formDataMap['prescription_required'] = prescriptionRequired;
      }

      final formData = FormData.fromMap(formDataMap);

      if (photoBytes != null && photoFileName != null) {
        formData.files.add(
          MapEntry(
            'medicine_photo',
            MultipartFile.fromBytes(photoBytes, filename: photoFileName),
          ),
        );
      }

      final response = await _dio.post(ApiUrls.medicineCreate, data: formData);
      final map = Map<String, dynamic>.from(response.data as Map);
      return Medicine.fromJson(map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['detail'] ?? 'Failed to create medicine',
        );
      }
      throw Exception('Failed to create medicine: $e');
    } catch (e) {
      throw Exception('Failed to create medicine: $e');
    }
  }

  Future<Map<String, dynamic>> uploadMedicinesCsv(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'file',
          MultipartFile.fromBytes(fileBytes, filename: fileName),
        ),
      );

      final response = await _dio.post(
        ApiUrls.medicineCreate,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 10),
        ),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to upload CSV');
      }
      throw Exception('Failed to upload CSV: $e');
    } catch (e) {
      throw Exception('Failed to upload CSV: $e');
    }
  }

  Future<Map<String, dynamic>> checkImportStatus(String jobId) async {
    try {
      final response = await _dio.get('${ApiUrls.medicineImportStatus}/$jobId');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to check status');
      }
      throw Exception('Failed to check import status: $e');
    } catch (e) {
      throw Exception('Failed to check import status: $e');
    }
  }

  Future<Map<String, dynamic>> searchMedicines({
    String? searchTerm,
    List<String>? priceRange,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['search_term'] = searchTerm;
      }
      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      if (priceRange != null && priceRange.isNotEmpty) {
        queryParams['price_range'] = priceRange;
      }

      final response = await _dio.get(
        ApiUrls.medicineSearch,
        queryParameters: queryParams,
      );

      final raw = response.data['data'] as List;
      final medicines = raw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Medicine.fromJson(map);
      }).toList();
      return {
        'total': response.data['total'],
        'page': response.data['page'],
        'limit': response.data['limit'],
        'medicines': medicines,
      };
    } catch (e) {
      throw Exception('Failed to search medicines: $e');
    }
  }

  Future<Medicine> updateMedicine({
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
    try {
      final formDataMap = <String, dynamic>{};

      if (medicineName != null) formDataMap['medicine_name'] = medicineName;
      if (medicineCategory != null)
        formDataMap['medicine_category'] = medicineCategory;
      if (medicineQuantity != null)
        formDataMap['medicine_quantity'] = medicineQuantity;
      if (mrp != null) formDataMap['mrp'] = mrp.toString();
      if (discountPercent != null) {
        formDataMap['discount_percent'] = discountPercent.toString();
      }
      if (medicineDescription != null) {
        formDataMap['medicine_description'] = medicineDescription;
      }
      if (medicineComposition != null) {
        formDataMap['medicine_composition'] = medicineComposition;
      }
      if (precautions != null) formDataMap['precautions'] = precautions;
      if (prescriptionRequired != null)
        formDataMap['prescription_required'] = prescriptionRequired;

      final formData = FormData.fromMap(formDataMap);

      if (photoBytes != null && photoFileName != null) {
        formData.files.add(
          MapEntry(
            'medicine_photo',
            MultipartFile.fromBytes(photoBytes, filename: photoFileName),
          ),
        );
      }

      final response = await _dio.put(
        '${ApiUrls.medicineUpdateById}/$medicineId',
        data: formData,
      );
      final map = Map<String, dynamic>.from(response.data as Map);
      return Medicine.fromJson(map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['detail'] ?? 'Failed to update medicine',
        );
      }
      throw Exception('Failed to update medicine: $e');
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  Future<void> deleteMedicines(List<String> medicineIds) async {
    try {
      await _dio.delete(
        ApiUrls.medicineDeleteByIds,
        data: medicineIds,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (e) {
      throw Exception('Failed to delete medicines: $e');
    }
  }
}
