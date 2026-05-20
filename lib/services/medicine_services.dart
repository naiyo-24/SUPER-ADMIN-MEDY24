import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:typed_data';
import '../models/medicine.dart';
import 'api_url.dart';

class MedicineServices {
  late final Dio _dio;

  MedicineServices() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiUrls.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  Future<Map<String, dynamic>> getAllMedicines({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiUrls.medicineGetAll,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
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

      final formData = FormData.fromMap(formDataMap);

      if (photoBytes != null && photoFileName != null) {
        formData.files.add(MapEntry(
          'medicine_photo',
          MultipartFile.fromBytes(
            photoBytes,
            filename: photoFileName,
          ),
        ));
      }

      final response = await _dio.post(
        ApiUrls.medicineCreate,
        data: formData,
      );
      final map = Map<String, dynamic>.from(response.data as Map);
      return Medicine.fromJson(map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to create medicine');
      }
      throw Exception('Failed to create medicine: $e');
    } catch (e) {
      throw Exception('Failed to create medicine: $e');
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
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};

      if (medicineName != null) formDataMap['medicine_name'] = medicineName;
      if (medicineCategory != null) formDataMap['medicine_category'] = medicineCategory;
      if (medicineQuantity != null) formDataMap['medicine_quantity'] = medicineQuantity;
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

      final formData = FormData.fromMap(formDataMap);

      if (photoBytes != null && photoFileName != null) {
        formData.files.add(MapEntry(
          'medicine_photo',
          MultipartFile.fromBytes(
            photoBytes,
            filename: photoFileName,
          ),
        ));
      }

      final response = await _dio.put(
        '${ApiUrls.medicineUpdateById}/$medicineId',
        data: formData,
      );
      final map = Map<String, dynamic>.from(response.data as Map);
      return Medicine.fromJson(map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to update medicine');
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
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to delete medicines: $e');
    }
  }
}
