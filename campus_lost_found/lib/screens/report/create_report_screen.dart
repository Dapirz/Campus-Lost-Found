import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedType = 'lost'; // 'lost' atau 'found'
  DateTime? _selectedDate;
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        title: const Text(
          'Create Report',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  _selectedType == 'found'
                      ? 'Report Found Item'
                      : 'Report Lost Item',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Help reunite someone with their lost belongings by providing details below.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Section: Jenis Laporan
                _buildTypeSelector(),
                const SizedBox(height: 12),

                // Section: Foto Barang
                _buildPhotoSection(),
                const SizedBox(height: 12),

                // Section: Detail Barang
                _buildItemDetailsSection(),
                const SizedBox(height: 12),

                // Section: Lokasi & Tanggal
                _buildWhereWhenSection(),
                const SizedBox(height: 24),

                // Tombol Submit
                _buildSubmitButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section: Jenis Laporan (custom radio cards)
  Widget _buildTypeSelector() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Type *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _typeCard(
                  'lost',
                  'Lost Item',
                  Icons.search_off,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _typeCard(
                  'found',
                  'Found Item',
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeCard(String type, String label, IconData icon, Color iconColor) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.primary : iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section: Foto Barang
  Widget _buildPhotoSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Item Photo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Max 3 photos, JPG/PNG format',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          // Upload area (jika belum ada foto)
          if (_selectedImages.isEmpty)
            GestureDetector(
              onTap: _pickFromGallery,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderDefault,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 36,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to upload a clear photo',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      'JPEG, PNG up to 2MB',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Preview foto yang sudah dipilih
          if (_selectedImages.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          entry.value,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedImages.removeAt(entry.key));
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Tombol pilih foto (jika belum 3)
          if (_selectedImages.isNotEmpty && _selectedImages.length < 3)
            Row(
              children: [
                _photoButton(
                  'Galeri',
                  Icons.photo_library_outlined,
                  _pickFromGallery,
                ),
                const SizedBox(width: 8),
                _photoButton(
                  'Kamera',
                  Icons.camera_alt_outlined,
                  _pickFromCamera,
                ),
              ],
            ),

          if (_selectedImages.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _photoButton(
                    'Choose from Gallery',
                    Icons.photo_library_outlined,
                    _pickFromGallery,
                  ),
                  const SizedBox(width: 8),
                  _photoButton(
                    'Kamera',
                    Icons.camera_alt_outlined,
                    _pickFromCamera,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _photoButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.borderDefault),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  /// Section: Detail Barang
  Widget _buildItemDetailsSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Item Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Judul
          _fieldLabel(
            'What did you ${_selectedType == 'found' ? 'find' : 'lose'}?',
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _titleController,
            decoration: _inputDecoration('e.g. Brown Leather Wallet'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Title is required';
              if (v.trim().length < 5) return 'Minimum 5 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Deskripsi
          _fieldLabel('Distinctive Features'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: _inputDecoration(
              'Any unique marks, brands, or contents that help identify it...',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Description is required';
              }
              if (v.trim().length < 10) return 'Minimum 10 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Section: Lokasi & Tanggal
  Widget _buildWhereWhenSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Where & When',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lokasi
          _fieldLabel(
            'Location ${_selectedType == 'found' ? 'Found' : 'Lost'}',
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _locationController,
            decoration: _inputDecoration('Address or place...').copyWith(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Location is required';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Tanggal
          _fieldLabel('Date'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: _inputDecoration('mm/dd/yyyy').copyWith(
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Date is required';
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Tombol Submit
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitReport,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.send_outlined, size: 18),
        label: Text(
          _isSubmitting
              ? 'Submitting...'
              : 'Submit ${_selectedType == 'found' ? 'Found' : 'Lost'} Item',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // === Actions ===

  Future<void> _pickFromGallery() async {
    if (_selectedImages.length >= 3) {
      _showSnackBar('Maximum 3 photos allowed', isError: true);
      return;
    }
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _selectedImages.add(File(picked.path)));
      }
    } catch (e) {
      _showSnackBar('Failed to select photo', isError: true);
    }
  }

  Future<void> _pickFromCamera() async {
    if (_selectedImages.length >= 3) {
      _showSnackBar('Maximum 3 photos allowed', isError: true);
      return;
    }
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _selectedImages.add(File(picked.path)));
      }
    } catch (e) {
      _showSnackBar('Failed to take photo', isError: true);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Format tampilan: dd MMMM yyyy
        const months = [
          '',
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        _dateController.text =
            '${picked.day} ${months[picked.month]} ${picked.year}';
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showSnackBar('Please select an incident date', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn || authProvider.token == null) {
      _showSnackBar('You must be logged in first', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    // Format tanggal untuk API: yyyy-MM-dd
    final apiDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    final reportProvider = context.read<ReportProvider>();
    final result = await reportProvider.createReport(
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      locationText: _locationController.text.trim(),
      incidentDate: apiDate,
      images: _selectedImages,
      token: authProvider.token!,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report submitted successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Your report will be reviewed by an admin',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        final errors = result['errors'];
        String errorMsg = result['message'] ?? 'Failed to submit report';
        if (errors != null && errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMsg = firstError.first.toString();
          }
        }
        _showSnackBar(errorMsg, isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // === UI Helpers ===

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.neutral,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
