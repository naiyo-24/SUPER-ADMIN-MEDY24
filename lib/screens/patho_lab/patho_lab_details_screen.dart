import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/patho_lab.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/patho_lab_provider.dart';
import '../../services/api_url.dart';

class PathoLabDetailsScreen extends ConsumerStatefulWidget {
  final PathoLab lab;
  const PathoLabDetailsScreen({super.key, required this.lab});

  @override
  ConsumerState<PathoLabDetailsScreen> createState() =>
      _PathoLabDetailsScreenState();
}

class _PathoLabDetailsScreenState extends ConsumerState<PathoLabDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  late TextEditingController _panController;
  late TextEditingController _nablController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyController;
  late TextEditingController _whatsappController;
  late TextEditingController _passwordController;
  String _status = 'active';
  bool _obscurePassword = true;

  PlatformFile? _logoFile;
  PlatformFile? _certFile;
  PlatformFile? _passbookFile;

  String? _currentLogoUrl;
  String? _currentCertName;
  String? _currentPassbookName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lab.labName);
    _mobileController = TextEditingController(text: widget.lab.mobileNumber);
    _emailController = TextEditingController(text: widget.lab.emailAddress);
    _gstController = TextEditingController(text: widget.lab.gstNumber);
    _panController = TextEditingController(text: widget.lab.panNumber);
    _nablController = TextEditingController(
      text: widget.lab.nablAccreditationNumber,
    );
    _addressController = TextEditingController(text: widget.lab.address);
    _emergencyController = TextEditingController(
      text: widget.lab.emergencyContactNumber,
    );
    _whatsappController = TextEditingController(
      text: widget.lab.whatsappNumber,
    );
    _passwordController = TextEditingController(text: widget.lab.password);
    _status = widget.lab.status;
    _currentLogoUrl = widget.lab.labLogoUrl;
    _currentCertName = widget.lab.registrationCertificateUrl.split('/').last;
    _currentPassbookName = widget.lab.bankPassbookUrl.split('/').last;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _nablController.dispose();
    _addressController.dispose();
    _emergencyController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        if (type == 'logo') {
          _logoFile = result.files.single;
        } else if (type == 'cert') {
          _certFile = result.files.single;
        } else if (type == 'passbook') {
          _passbookFile = result.files.single;
        }
      });
    }
  }

  void _saveChanges() async {
    final Map<String, dynamic> data = {
      'lab_name': _nameController.text,
      'mobile_number': _mobileController.text,
      'email_address': _emailController.text,
      'gst_number': _gstController.text,
      'pan_number': _panController.text,
      'nabl_accreditation_number': _nablController.text,
      'address': _addressController.text,
      'emergency_contact_number': _emergencyController.text,
      'whatsapp_number': _whatsappController.text,
      'password': _passwordController.text,
      'status': _status,
    };

    final formData = FormData.fromMap(data);

    if (_logoFile != null) {
      if (kIsWeb) {
        formData.files.add(
          MapEntry(
            'lab_logo',
            MultipartFile.fromBytes(
              _logoFile!.bytes!,
              filename: _logoFile!.name,
            ),
          ),
        );
      } else {
        formData.files.add(
          MapEntry('lab_logo', await MultipartFile.fromFile(_logoFile!.path!)),
        );
      }
    }

    if (_certFile != null) {
      if (kIsWeb) {
        formData.files.add(
          MapEntry(
            'registration_certificate',
            MultipartFile.fromBytes(
              _certFile!.bytes!,
              filename: _certFile!.name,
            ),
          ),
        );
      } else {
        formData.files.add(
          MapEntry(
            'registration_certificate',
            await MultipartFile.fromFile(_certFile!.path!),
          ),
        );
      }
    }

    if (_passbookFile != null) {
      if (kIsWeb) {
        formData.files.add(
          MapEntry(
            'bank_passbook',
            MultipartFile.fromBytes(
              _passbookFile!.bytes!,
              filename: _passbookFile!.name,
            ),
          ),
        );
      } else {
        formData.files.add(
          MapEntry(
            'bank_passbook',
            await MultipartFile.fromFile(_passbookFile!.path!),
          ),
        );
      }
    }

    try {
      await ref
          .read(pathoLabProvider.notifier)
          .updateLab(widget.lab.labId, formData);
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (_status.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        break;
      case 'suspended':
        statusColor = AppColors.warning;
        break;
      case 'terminated':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textTertiary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Partner Intelligence',
        subtitle: 'Entity # ${widget.lab.labId}',
        showBackButton: true,
        actions: [
          if (!_isEditing) ...[
            CustomAppBar.buildActionButton(
              icon: IconsaxPlusLinear.edit,
              onTap: () => setState(() => _isEditing = true),
            ),
            CustomAppBar.buildActionButton(
              icon: IconsaxPlusLinear.trash,
              iconColor: AppColors.error,
              onTap: () {},
            ),
          ] else ...[
            CustomAppBar.buildActionButton(
              icon: IconsaxPlusLinear.tick_square,
              iconColor: AppColors.success,
              onTap: _saveChanges,
            ),
            CustomAppBar.buildActionButton(
              icon: IconsaxPlusLinear.close_square,
              iconColor: AppColors.error,
              onTap: () => setState(() => _isEditing = false),
            ),
          ],
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(statusColor),
            const SizedBox(height: 32),

            // Content Sections
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Credentials & Legal
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        'Core Credentials',
                        IconsaxPlusLinear.personalcard,
                        [
                          _buildDetailField('Official Business Name', _nameController, IconsaxPlusLinear.hospital),
                          Row(
                            children: [
                              Expanded(child: _buildDetailField('Primary Mobile', _mobileController, IconsaxPlusLinear.call)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDetailField('WhatsApp Business', _whatsappController, IconsaxPlusLinear.sms)),
                            ],
                          ),
                          _buildDetailField('Business Email', _emailController, IconsaxPlusLinear.sms),
                          _buildDetailField(
                            'Access Password',
                            _passwordController,
                            IconsaxPlusLinear.key,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        'Compliance & Operational',
                        IconsaxPlusLinear.verify,
                        [
                          Row(
                            children: [
                              Expanded(child: _buildDetailField('GST No', _gstController, IconsaxPlusLinear.percentage_square)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDetailField('PAN No', _panController, IconsaxPlusLinear.card_pos)),
                            ],
                          ),
                          _buildDetailField('NABL Accreditation No', _nablController, IconsaxPlusLinear.award),
                          _buildDetailField('Physical Operation Address', _addressController, IconsaxPlusLinear.location, maxLines: 2),
                          _buildDetailField('Emergency Contact', _emergencyController, IconsaxPlusLinear.call_calling),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Documents & Status
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildStatusCard(statusColor),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        'Legal Documentation',
                        IconsaxPlusLinear.document_text,
                        [
                          _buildDocumentTile(
                            'Registration Certificate',
                            _certFile?.name ?? _currentCertName ?? 'No File',
                            () => _pickFile('cert'),
                            url: widget.lab.registrationCertificateUrl,
                          ),
                          const SizedBox(height: 16),
                          _buildDocumentTile(
                            'Bank Passbook Copy',
                            _passbookFile?.name ?? _currentPassbookName ?? 'No File',
                            () => _pickFile('passbook'),
                            url: widget.lab.bankPassbookUrl,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 40, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 6),
                  boxShadow: [
                    BoxShadow(color: statusColor.withAlpha(20), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: ClipOval(
                  child: _logoFile != null
                      ? (kIsWeb ? Image.memory(_logoFile!.bytes!, fit: BoxFit.cover) : Image.network('file://${_logoFile!.path}', fit: BoxFit.cover))
                      : Image.network(
                          _currentLogoUrl != null && _currentLogoUrl!.isNotEmpty
                              ? (_currentLogoUrl!.startsWith('http') ? _currentLogoUrl! : '${ApiUrls.baseUrl}${_currentLogoUrl!.startsWith('/') ? _currentLogoUrl!.substring(1) : _currentLogoUrl}')
                              : 'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: AppColors.background, child: Icon(IconsaxPlusLinear.hospital, color: statusColor, size: 50)),
                        ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickFile('logo'),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: const Icon(IconsaxPlusLinear.camera, color: Colors.white, size: 18),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lab.labName,
                  style: AppTextStyles.header.copyWith(fontSize: 36, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(IconsaxPlusLinear.location, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(widget.lab.address, style: AppTextStyles.description),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildHeaderTag('NABL CERTIFIED', AppColors.primary),
                    _buildHeaderTag('PREMIUM PARTNER', AppColors.purple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }

  Widget _buildStatusCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Operational Status', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isEditing
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _status,
                      isExpanded: true,
                      onChanged: (v) => setState(() => _status = v!),
                      items: ['pending', 'active', 'suspended', 'terminated'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                    ),
                  ),
                )
              : Text(_status.toUpperCase(), style: AppTextStyles.header.copyWith(fontSize: 24, color: statusColor, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: _isEditing,
            maxLines: maxLines,
            obscureText: isPassword && obscureText,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: _isEditing ? AppColors.primary : AppColors.textTertiary),
              suffixIcon: isPassword
                  ? IconButton(icon: Icon(obscureText ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye, size: 18), onPressed: onToggleVisibility)
                  : null,
              filled: true,
              fillColor: _isEditing ? Colors.white : AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider.withAlpha(50))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String label, String fileName, VoidCallback onPick, {String? url}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(IconsaxPlusLinear.document_code, color: AppColors.textSecondary),
              const SizedBox(width: 16),
              Expanded(child: Text(fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              if (_isEditing)
                IconButton(icon: const Icon(IconsaxPlusLinear.add_circle, size: 20, color: AppColors.primary), onPressed: onPick)
              else if (url != null && url.isNotEmpty)
                IconButton(
                  icon: const Icon(IconsaxPlusLinear.export_1, size: 20, color: AppColors.primary),
                  onPressed: () async {
                    final fullUrl = url.startsWith('http') ? url : '${ApiUrls.baseUrl}${url.startsWith('/') ? url.substring(1) : url}';
                    if (await canLaunchUrl(Uri.parse(fullUrl))) await launchUrl(Uri.parse(fullUrl));
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
