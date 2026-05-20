import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../providers/medicine_provider.dart';

class MedicineCsvFileUpload {
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  static Future<void> uploadCsv(BuildContext context, WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final bytes = result.files.first.bytes!;
        final csvString = utf8.decode(bytes);
        final lines = const LineSplitter().convert(csvString);

        if (lines.isEmpty) {
          throw Exception('CSV file is empty');
        }

        final headers = _parseCsvLine(
          lines.first,
        ).map((e) => e.trim().toLowerCase()).toList();

        // Find indices
        final nameIndex = headers.indexOf('medicine_name');
        final categoryIndex = headers.indexOf('medicine_category');
        final quantityIndex = headers.indexOf('medicine_quantity');
        final mrpIndex = headers.indexOf('mrp');
        final discountIndex = headers.indexOf('discount_percent');
        final descIndex = headers.indexOf('medicine_description');
        final compIndex = headers.indexOf('medicine_composition');
        final precIndex = headers.indexOf('precautions');

        if (nameIndex == -1 ||
            categoryIndex == -1 ||
            quantityIndex == -1 ||
            mrpIndex == -1) {
          throw Exception(
            'Missing required columns. Required: medicine_name, medicine_category, medicine_quantity, mrp',
          );
        }

        int successCount = 0;
        final notifier = ref.read(medicineNotifierProvider.notifier);

        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final values = _parseCsvLine(line);

          // Skip if missing required minimum values for this row
          if (values.length <= mrpIndex ||
              values.length <= nameIndex ||
              values.length <= categoryIndex ||
              values.length <= quantityIndex) {
            continue;
          }

          final name = values[nameIndex].trim();
          final category = values[categoryIndex].trim();
          final quantity = values[quantityIndex].trim();
          final mrpStr = values[mrpIndex].trim();
          final mrp = double.tryParse(mrpStr) ?? 0.0;

          double? discountPercent;
          if (discountIndex != -1 && values.length > discountIndex) {
            final dStr = values[discountIndex].trim();
            if (dStr.isNotEmpty) {
              discountPercent = double.tryParse(dStr);
            }
          }

          String? desc;
          if (descIndex != -1 && values.length > descIndex) {
            desc = values[descIndex].trim();
          }

          String? comp;
          if (compIndex != -1 && values.length > compIndex) {
            comp = values[compIndex].trim();
          }

          String? precJson;
          if (precIndex != -1 && values.length > precIndex) {
            final rawPrec = values[precIndex].trim();
            final precList = rawPrec
                .split(';')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            precJson = jsonEncode(precList);
          }

          if (name.isNotEmpty && category.isNotEmpty) {
            try {
              final created = await notifier.createMedicine(
                medicineName: name,
                medicineCategory: category,
                medicineQuantity: quantity,
                mrp: mrp,
                discountPercent:
                    (discountPercent != null && discountPercent > 0)
                        ? discountPercent
                        : null,
                medicineDescription: desc,
                medicineComposition: comp,
                precautions: precJson,
              );
              if (created != null) successCount++;
            } catch (e) {
              if (kDebugMode) {
                print('Error creating medicine row $i: $e');
              }
            }
          }
        }

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully imported $successCount medicines from CSV',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
