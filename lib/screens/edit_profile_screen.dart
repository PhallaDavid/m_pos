import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_text_field.dart';
import '../widgets/app_icon_button.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/settings_skeleton.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _merchantNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeEmailController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeAddressController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await ApiService.getProfile();
      setState(() {
        _merchantNameController.text = data['name'] ?? '';
        _storeNameController.text = data['store_name'] ?? '';
        _storeEmailController.text = ApiService.userEmail ?? '';
        _storePhoneController.text = data['phone'] ?? '';
        _storeAddressController.text = data['address'] ?? '';
        _imageUrl = data['image_url'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppToast.show(
        context,
        'Failed to load profile: ${e.toString().replaceAll("Exception: ", "")}',
        type: ToastType.error,
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final bytes = await image.readAsBytes();
      final url = await ApiService.uploadImage(bytes, image.name);

      Navigator.pop(context); // close loader

      setState(() {
        _imageUrl = url;
      });

      AppToast.show(
        context,
        'Avatar uploaded successfully!',
        type: ToastType.success,
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // close loader
      AppToast.show(
        context,
        'Upload failed: ${e.toString().replaceAll("Exception: ", "")}',
        type: ToastType.error,
      );
    }
  }

  @override
  void dispose() {
    _merchantNameController.dispose();
    _storeNameController.dispose();
    _storeEmailController.dispose();
    _storePhoneController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
          child: AppIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const SettingsSkeleton()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Centered Photo Editor
                        Center(
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? const Color(0xFF0F2B66)
                                        : AppColors.primaryLight,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : AppColors.borderLight,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child:
                                        _imageUrl != null &&
                                            _imageUrl!.isNotEmpty
                                        ? Image.network(
                                            _imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, err, stack) => Icon(
                                                  Icons.store_rounded,
                                                  size: 40,
                                                  color: isDark
                                                      ? const Color(0xFF5CC8FF)
                                                      : AppColors.primary,
                                                ),
                                          )
                                        : Icon(
                                            Icons.store_rounded,
                                            size: 40,
                                            color: isDark
                                                ? const Color(0xFF5CC8FF)
                                                : AppColors.primary,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.success,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merchant Owner Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            RoundedTextField(
                              controller: _merchantNameController,
                              hintText: 'e.g. John Doe',
                              prefixIcon: Icons.person_rounded,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Store Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            RoundedTextField(
                              controller: _storeNameController,
                              hintText: 'Central Coffee Hub',
                              prefixIcon: Icons.store_rounded,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Store Contact Email (Read Only)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            RoundedTextField(
                              controller: _storeEmailController,
                              hintText: 'contact@coffeehub.com',
                              prefixIcon: Icons.mail_rounded,
                              readOnly: true,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Store Contact Phone',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            RoundedTextField(
                              controller: _storePhoneController,
                              hintText: '+1 (555) 000-0000',
                              prefixIcon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Store Address',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            RoundedTextField(
                              controller: _storeAddressController,
                              hintText: 'e.g. 123 Oak Road, City',
                              prefixIcon: Icons.location_on_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32.0),

                        PrimaryButton(
                          text: 'Save Details',
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              await ApiService.updateProfile(
                                name: _merchantNameController.text.trim(),
                                storeName: _storeNameController.text.trim(),
                                phone: _storePhoneController.text.trim(),
                                address: _storeAddressController.text.trim(),
                                imageUrl: _imageUrl ?? '',
                              );

                              Navigator.pop(context); // close loader

                              AppToast.show(
                                context,
                                'Profile details saved successfully',
                                type: ToastType.success,
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              Navigator.pop(context); // close loader
                              AppToast.show(
                                context,
                                'Save failed: ${e.toString().replaceAll("Exception: ", "")}',
                                type: ToastType.error,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
