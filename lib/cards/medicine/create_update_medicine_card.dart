import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine.dart';

class CreateUpdateMedicineCard extends ConsumerStatefulWidget {
  final Medicine? medicine;

  const CreateUpdateMedicineCard({super.key, this.medicine});

  @override
  ConsumerState<CreateUpdateMedicineCard> createState() => _CreateUpdateMedicineCardState();
}

class _CreateUpdateMedicineCardState extends ConsumerState<CreateUpdateMedicineCard> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _mrpController;
  late TextEditingController _discountController;
  late TextEditingController _descriptionController;
  late TextEditingController _compositionController;
  late TextEditingController _precautionsController;

  String _prescriptionRequired = 'false';
  PlatformFile? _selectedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.medicineName ?? '');
    _categoryController = TextEditingController(text: widget.medicine?.medicineCategory ?? '');
    _quantityController = TextEditingController(text: widget.medicine?.medicineQuantity ?? '');
    _mrpController = TextEditingController(text: widget.medicine?.mrp.toString() ?? '');
    _discountController = TextEditingController(
      text: widget.medicine?.discountPercent != null
          ? widget.medicine!.discountPercent!.toString()
          : '',
    );
    _descriptionController = TextEditingController(text: widget.medicine?.medicineDescription ?? '');
    _compositionController = TextEditingController(text: widget.medicine?.medicineComposition ?? '');
    
    String precautionsText = '';
    if (widget.medicine != null) {
      precautionsText = widget.medicine!.precautions.join(', ');
      _prescriptionRequired = widget.medicine!.prescriptionRequired == 'true' ? 'true' : 'false';
    }
    _precautionsController = TextEditingController(text: precautionsText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _mrpController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _compositionController.dispose();
    _precautionsController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedPhoto = result.files.first;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mrp = double.tryParse(_mrpController.text) ?? 0.0;
      final discountRaw = _discountController.text.trim();
      double? discountPercent;
      if (discountRaw.isNotEmpty) {
        discountPercent = double.tryParse(discountRaw);
      }

      final precautionsList = _precautionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
          
      final precautionsJson = jsonEncode(precautionsList);

      final notifier = ref.read(medicineNotifierProvider.notifier);

      bool ok;
      if (widget.medicine == null) {
        final created = await notifier.createMedicine(
          medicineName: _nameController.text,
          medicineCategory: _categoryController.text,
          medicineQuantity: _quantityController.text,
          mrp: mrp,
          discountPercent: (discountPercent != null && discountPercent > 0)
              ? discountPercent
              : null,
          medicineDescription: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          medicineComposition: _compositionController.text.isNotEmpty ? _compositionController.text : null,
          precautions: precautionsJson,
          prescriptionRequired: _prescriptionRequired,
          photoBytes: _selectedPhoto?.bytes,
          photoFileName: _selectedPhoto?.name,
        );
        ok = created != null;
      } else {
        final updated = await notifier.updateMedicine(
          medicineId: widget.medicine!.medicineId,
          medicineName: _nameController.text,
          medicineCategory: _categoryController.text,
          medicineQuantity: _quantityController.text,
          mrp: mrp,
          discountPercent: discountPercent ?? 0,
          medicineDescription: _descriptionController.text,
          medicineComposition: _compositionController.text,
          precautions: precautionsJson,
          prescriptionRequired: _prescriptionRequired,
          photoBytes: _selectedPhoto?.bytes,
          photoFileName: _selectedPhoto?.name,
        );
        ok = updated != null;
      }

      if (!ok && mounted) {
        final message =
            ref.read(medicineNotifierProvider).error ?? 'Request failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.medicine == null
                ? 'Medicine created successfully'
                : 'Medicine updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.medicine == null ? 'Create New Medicine' : 'Update Medicine',
                style: AppTextStyles.header.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(IconsaxPlusLinear.close_circle),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: AppTheme.inputDecoration('Medicine Name *'),
                            validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: AppTheme.inputDecoration('Category *'),
                            validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: AppTheme.inputDecoration('Quantity * (e.g. 10 Tablets)'),
                            validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _mrpController,
                            decoration: AppTheme.inputDecoration('MRP (₹) *'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required field';
                              if (double.tryParse(value) == null) return 'Enter a valid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            decoration: AppTheme.inputDecoration('Discount % (optional)'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return null;
                              final d = double.tryParse(value.trim());
                              if (d == null) return 'Enter a valid number';
                              if (d < 0 || d > 100) return 'Must be between 0 and 100';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppTheme.inputDecoration('Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _compositionController,
                      decoration: AppTheme.inputDecoration('Composition'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precautionsController,
                            decoration: AppTheme.inputDecoration('Precautions (comma separated)'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: AppTheme.inputDecoration('Prescription Required?'),
                            value: _prescriptionRequired,
                            items: const [
                              DropdownMenuItem(value: 'true', child: Text('Yes')),
                              DropdownMenuItem(value: 'false', child: Text('No')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _prescriptionRequired = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.background,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: _selectedPhoto != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(_selectedPhoto!.bytes!, fit: BoxFit.cover),
                                  )
                                : const Icon(IconsaxPlusLinear.image, color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Medicine Photo', style: AppTextStyles.cardTitle),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedPhoto?.name ?? 'No file selected. Supported formats: JPG, PNG',
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickPhoto,
                            icon: const Icon(IconsaxPlusLinear.document_upload, size: 16, color: Colors.white),
                            label: const Text('UPLOAD', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.medicine == null ? 'CREATE MEDICINE' : 'UPDATE MEDICINE',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
