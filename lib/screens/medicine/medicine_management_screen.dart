import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../notifiers/medicine_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../providers/medicine_provider.dart';
import '../../cards/medicine/medicine_management_table_card.dart';
import '../../cards/medicine/medicine_search_filter_card.dart';
import '../../cards/medicine/create_update_medicine_card.dart';
import '../../utils/medicine_csv_file_upload.dart';

class MedicineManagementScreen extends ConsumerStatefulWidget {
  const MedicineManagementScreen({super.key});

  @override
  ConsumerState<MedicineManagementScreen> createState() =>
      _MedicineManagementScreenState();
}

class _MedicineManagementScreenState
    extends ConsumerState<MedicineManagementScreen> {
  bool _isSearchVisible = false;

  void _showCreateUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(24),
        child: CreateUpdateMedicineCard(),
      ),
    );
  }

  void _handleCsvUpload() async {
    await MedicineCsvFileUpload.uploadCsv(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final medicineState = ref.watch(medicineNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideNavBar(),
      appBar: CustomAppBar(
        title: 'Medicine Management',
        subtitle: 'Core Pharmacy Intelligence',
        showDrawer: true,
        actions: [
          CustomAppBar.buildActionButton(
            icon: _isSearchVisible
                ? IconsaxPlusLinear.search_status
                : IconsaxPlusLinear.search_normal_1,
            iconColor: _isSearchVisible ? AppColors.primaryAccent : null,
            onTap: () => setState(() => _isSearchVisible = !_isSearchVisible),
          ),
          CustomAppBar.buildActionButton(
            icon: IconsaxPlusLinear.document_upload,
            onTap: _handleCsvUpload,
          ),
          CustomAppBar.buildActionButton(
            icon: IconsaxPlusLinear.document_download,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _buildCreateButton(),
          const SizedBox(width: AppSpacing.screenPadding),
        ],
      ),
      body: medicineState.isLoading && medicineState.medicines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(medicineNotifierProvider.notifier)
                  .fetchMedicines(page: 1),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 32),
                  if (_isSearchVisible) ...[
                    const MedicineSearchFilterCard(),
                    const SizedBox(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medicines Catalogue',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Central repository of all available medicines',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${medicineState.total} MEDICINES',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (medicineState.medicines.isEmpty)
                    _buildEmptyState()
                  else ...[
                    const MedicineManagementTableCard(),
                    const SizedBox(height: 32),
                    _buildPagination(medicineState),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildPagination(MedicineState state) {
    final totalPages = (state.total / state.limit).ceil();
    final currentPage = state.currentPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: IconButton(
            onPressed: currentPage > 1
                ? () => ref
                      .read(medicineNotifierProvider.notifier)
                      .fetchMedicines(page: currentPage - 1)
                : null,
            icon: Icon(
              IconsaxPlusLinear.arrow_left,
              color: currentPage > 1
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Page $currentPage of $totalPages',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: IconButton(
            onPressed: currentPage < totalPages
                ? () => ref
                      .read(medicineNotifierProvider.notifier)
                      .fetchMedicines(page: currentPage + 1)
                : null,
            icon: Icon(
              IconsaxPlusLinear.arrow_right_1,
              color: currentPage < totalPages
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pharmacy Inventory 👋',
          style: AppTextStyles.header.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and curate the master medicine catalogue.',
          style: AppTextStyles.description.copyWith(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryAccent],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _showCreateUpdateDialog,
        icon: const Icon(
          IconsaxPlusLinear.add_square,
          size: 18,
          color: Colors.white,
        ),
        label: const Text(
          'NEW MEDICINE',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 40),
                ],
              ),
              child: const Icon(
                IconsaxPlusLinear.search_status,
                size: 64,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Medicines Found',
              style: AppTextStyles.subHeader.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different term or create a new medicine.',
              style: AppTextStyles.description.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
