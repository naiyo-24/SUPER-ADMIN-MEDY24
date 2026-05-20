import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';
import 'create_update_medicine_card.dart';
import 'medicine_image_preview_card.dart';

class MedicineManagementTableCard extends ConsumerWidget {
  const MedicineManagementTableCard({super.key});

  void _showCreateUpdateDialog(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: CreateUpdateMedicineCard(medicine: medicine),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(200),
      builder: (context) => MedicineImagePreviewCard(imageUrl: imageUrl),
    );
  }

  void _deleteMedicine(
    BuildContext context,
    WidgetRef ref,
    Medicine medicine,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text(
          'Are you sure you want to delete ${medicine.medicineName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(medicineNotifierProvider.notifier)
          .deleteMedicines([medicine.medicineId]);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicineState = ref.watch(medicineNotifierProvider);
    final medicines = medicineState.filteredMedicines;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.background),
          dataRowMinHeight: 70,
          dataRowMaxHeight: 70,
          headingTextStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          columns: const [
            DataColumn(label: Text('PHOTO')),
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('NAME')),
            DataColumn(label: Text('CATEGORY')),
            DataColumn(label: Text('QTY')),
            DataColumn(label: Text('MRP (₹)')),
            DataColumn(label: Text('DISC %')),
            DataColumn(label: Text('FINAL (₹)')),
            DataColumn(label: Text('DESCRIPTION')),
            DataColumn(label: Text('COMPOSITION')),
            DataColumn(label: Text('PRECAUTIONS')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: medicines.map((medicine) {
            return DataRow(
              cells: [
                DataCell(
                  medicine.medicinePhoto != null
                      ? GestureDetector(
                          onTap: () {
                            final imageUrl =
                                medicine.medicinePhoto!.startsWith('http')
                                ? medicine.medicinePhoto!
                                : '${ApiUrls.baseUrl}${medicine.medicinePhoto}';
                            _showImagePreview(context, imageUrl);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  medicine.medicinePhoto!.startsWith('http')
                                      ? medicine.medicinePhoto!
                                      : '${ApiUrls.baseUrl}${medicine.medicinePhoto}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            IconsaxPlusLinear.image,
                            color: AppColors.textTertiary,
                          ),
                        ),
                ),
                DataCell(
                  Text(
                    medicine.medicineId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    medicine.medicineName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      medicine.medicineCategory,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    medicine.medicineQuantity,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    '₹${medicine.mrp.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    medicine.discountPercent != null
                        ? '${medicine.discountPercent!.toStringAsFixed(1)}%'
                        : '—',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    '₹${medicine.finalSellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      medicine.medicineDescription ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      medicine.medicineComposition ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      medicine.precautions.map((e) => e.toString()).join(', '),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          IconsaxPlusLinear.edit_2,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            _showCreateUpdateDialog(context, medicine),
                      ),
                      IconButton(
                        icon: const Icon(
                          IconsaxPlusLinear.trash,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _deleteMedicine(context, ref, medicine),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
