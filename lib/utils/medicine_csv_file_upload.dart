import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/medicine_provider.dart';

class MedicineCsvFileUpload {
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
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Uploading and Processing CSV...'),
                    SizedBox(height: 8),
                    Text('This may take a while for large files.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        );

        final notifier = ref.read(medicineNotifierProvider.notifier);
        final file = result.files.first;

        final uploadResult = await notifier.uploadCsv(file.bytes!, file.name);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          if (uploadResult != null) {
            final successful = uploadResult['successful'] ?? 0;
            final failed = uploadResult['failed'] ?? 0;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Upload complete. Successful: $successful, Failed: $failed',
                ),
                backgroundColor: failed == 0 ? Colors.green : Colors.orange,
              ),
            );
          } else {
            final error =
                ref.read(medicineNotifierProvider).error ?? 'Upload failed';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
