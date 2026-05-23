import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';
import '../../providers/medicine_provider.dart';

class MedicineSearchFilterCard extends ConsumerStatefulWidget {
  const MedicineSearchFilterCard({super.key});

  @override
  ConsumerState<MedicineSearchFilterCard> createState() =>
      _MedicineSearchFilterCardState();
}

class _MedicineSearchFilterCardState
    extends ConsumerState<MedicineSearchFilterCard> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory = 'All';
  String? _selectedPriceRange = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filter',
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _searchController,
                  decoration:
                      AppTheme.inputDecoration(
                        'Search by Medicine Name or ID...',
                      ).copyWith(
                        prefixIcon: const Icon(
                          IconsaxPlusLinear.search_normal_1,
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                  onChanged: (value) {
                    ref
                        .read(medicineNotifierProvider.notifier)
                        .filterMedicines(
                          query: value,
                          category: _selectedCategory,
                          priceRange: _selectedPriceRange,
                        );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    'Category',
                  ).copyWith(filled: true, fillColor: AppColors.background),
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All Categories'),
                    ),
                    DropdownMenuItem(value: 'Tablet', child: Text('Tablet')),
                    DropdownMenuItem(value: 'Capsule', child: Text('Capsule')),
                    DropdownMenuItem(value: 'Syrup', child: Text('Syrup')),
                    DropdownMenuItem(
                      value: 'Injection',
                      child: Text('Injection'),
                    ),
                  ],
                  initialValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    ref
                        .read(medicineNotifierProvider.notifier)
                        .filterMedicines(
                          query: _searchController.text,
                          category: value,
                          priceRange: _selectedPriceRange,
                        );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    'Selling price',
                  ).copyWith(filled: true, fillColor: AppColors.background),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Prices')),
                    DropdownMenuItem(value: 'Under 100', child: Text('Under ₹100')),
                    DropdownMenuItem(value: '100-500', child: Text('₹100 - ₹500')),
                    DropdownMenuItem(value: '500-1000', child: Text('₹500 - ₹1000')),
                    DropdownMenuItem(value: '1000-5000', child: Text('₹1000 - ₹5000')),
                    DropdownMenuItem(value: 'Above 5000', child: Text('Above ₹5000')),
                  ],
                  initialValue: _selectedPriceRange,
                  onChanged: (value) {
                    setState(() => _selectedPriceRange = value);
                    ref
                        .read(medicineNotifierProvider.notifier)
                        .filterMedicines(
                          query: _searchController.text,
                          category: _selectedCategory,
                          priceRange: value,
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
