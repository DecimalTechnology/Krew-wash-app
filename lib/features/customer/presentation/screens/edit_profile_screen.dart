import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/edit_profile_provider.dart';
import '../widgets/edit_profile_otp_dialog.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../../core/widgets/country_code_picker.dart';
import '../../presentation/providers/package_provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/network_error_dialog.dart';
import '../../../../core/utils/network_error_utils.dart';
import '../../data/repositories/package_repository.dart';
import '../../domain/models/building_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneDisplayController = TextEditingController();
  final _emailController = TextEditingController();
  final _buildingSearchController = TextEditingController();
  final LayerLink _buildingFieldLink = LayerLink();
  OverlayEntry? _buildingSuggestionsOverlay;
  Timer? _searchDebounce;

  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingEmail = false;
  bool _isEditingBuilding = false;

  String? _selectedBuildingId;
  String? _selectedBuildingName;
  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  // Country code for phone number
  CountryCode _selectedCountryCode = const CountryCode(
    name: 'United Arab Emirates',
    code: 'AE',
    dialCode: '+971',
    flag: '🇦🇪',
  );

  @override
  void initState() {
    super.initState();
    // Delay loading user data until widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.name ?? '';

      // Extract country code from phone if it starts with +
      final phoneStr = user.phone?.toString() ?? '';
      if (phoneStr.startsWith('+')) {
        // Get all available country codes and sort by length (longest first)
        // This ensures we match +971 before +9, +91 before +9, etc.
        final allCountries = _getAllCountryCodes();
        allCountries.sort(
          (a, b) => b.dialCode.length.compareTo(a.dialCode.length),
        );

        CountryCode? matchedCountry;
        String remainingPhone = phoneStr;

        // Try to match country codes from longest to shortest
        for (final country in allCountries) {
          if (phoneStr.startsWith(country.dialCode)) {
            matchedCountry = country;
            remainingPhone = phoneStr.substring(country.dialCode.length).trim();
            break;
          }
        }

        if (matchedCountry != null) {
          _selectedCountryCode = matchedCountry;
          _phoneController.text = remainingPhone;
          _syncPhoneDisplay();
        } else {
          // If no match found, try to extract first 1-4 digits as country code
          final match = RegExp(r'^\+(\d{1,4})').firstMatch(phoneStr);
          if (match != null) {
            final dialCode = '+${match.group(1)}';
            final remainingPhone = phoneStr.substring(match.end).trim();
            _phoneController.text = remainingPhone;
            // Try to find country, keep default if not found
            final country = _findCountryByDialCode(dialCode);
            if (country != null) {
              _selectedCountryCode = country;
            }
            _syncPhoneDisplay();
          } else {
            _phoneController.text = phoneStr;
            _syncPhoneDisplay();
          }
        }
      } else {
        // If phone doesn't start with +, try to detect country code
        // Get all country codes and try matching from longest to shortest
        final allCountries = _getAllCountryCodes();
        allCountries.sort(
          (a, b) => b.dialCode.length.compareTo(a.dialCode.length),
        );

        bool found = false;
        for (final country in allCountries) {
          // Remove + from dial code for comparison
          final codeWithoutPlus = country.dialCode.substring(1);
          if (phoneStr.startsWith(codeWithoutPlus) &&
              phoneStr.length > codeWithoutPlus.length) {
            _selectedCountryCode = country;
            _phoneController.text = phoneStr
                .substring(codeWithoutPlus.length)
                .trim();
            found = true;
            break;
          }
        }

        if (!found) {
          // Default: assume it's just the number without country code
          _phoneController.text = phoneStr;
        }
        _syncPhoneDisplay();
      }

      _emailController.text = user.email ?? '';

      // Load building ID from user data if available
      if (user.buildingId != null && user.buildingId!.isNotEmpty) {
        _selectedBuildingId = user.buildingId;
        // Fetch building name to display in the field
        _fetchBuildingName(user.buildingId!);
      }
    }
  }

  void _syncPhoneDisplay() {
    final phoneNumber = _phoneController.text.trim();
    final full = phoneNumber.isNotEmpty
        ? '${_selectedCountryCode.dialCode}$phoneNumber'
        : '';
    _phoneDisplayController.text = full;
  }

  Future<void> _fetchBuildingName(String buildingId) async {
    try {
      final packageProvider = context.read<PackageProvider>();
      // Check if building name is already available in package provider
      if (packageProvider.selectedBuildingId == buildingId &&
          (packageProvider.selectedBuildingName ?? '').isNotEmpty) {
        setState(() {
          _selectedBuildingName = packageProvider.selectedBuildingName;
          _buildingSearchController.text = _selectedBuildingName!;
        });
        return;
      }

      // Fetch building name by searching buildings
      final repo = const PackageRepository();

      // Try empty search first (usually returns all buildings or a good subset)
      try {
        final buildings = await repo.searchBuildings('');
        final building = buildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () => BuildingModel(id: buildingId, buildingName: ''),
        );
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _selectedBuildingName = building.buildingName;
            _buildingSearchController.text = building.buildingName;
            // Also update the package provider for consistency
            packageProvider.selectBuilding(
              id: buildingId,
              name: building.buildingName,
            );
          });
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error in empty search: $e');
        }
      }

      // If empty search didn't work, try searching with the building ID itself
      try {
        final buildings = await repo.searchBuildings(buildingId);
        final building = buildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () => BuildingModel(id: buildingId, buildingName: ''),
        );
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _selectedBuildingName = building.buildingName;
            _buildingSearchController.text = building.buildingName;
            // Also update the package provider for consistency
            packageProvider.selectBuilding(
              id: buildingId,
              name: building.buildingName,
            );
          });
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error in ID search: $e');
        }
      }

      // If still not found, try a few common search terms to get more results
      final searchTerms = ['a', 'e', 'i', 'the'];
      for (final term in searchTerms) {
        try {
          final buildings = await repo.searchBuildings(term);
          final building = buildings.firstWhere(
            (b) => b.id == buildingId,
            orElse: () => BuildingModel(id: buildingId, buildingName: ''),
          );
          if (building.buildingName.isNotEmpty && mounted) {
            setState(() {
              _selectedBuildingName = building.buildingName;
              _buildingSearchController.text = building.buildingName;
              // Also update the package provider for consistency
              packageProvider.selectBuilding(
                id: buildingId,
                name: building.buildingName,
              );
            });
            return;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error searching with "$term": $e');
          }
          continue;
        }
      }

      // If all strategies fail, leave the field empty or show placeholder
      // Don't show the building ID as it's not user-friendly
      if (mounted) {
        setState(() {
          _selectedBuildingName = null;
          _buildingSearchController.clear();
        });
        if (kDebugMode) {
          print('Could not find building name for ID: $buildingId');
        }
      }
    } catch (e) {
      // Log error for debugging
      if (kDebugMode) {
        print('Error fetching building name: $e');
      }
      // If fetching fails, leave the field empty
      if (mounted) {
        setState(() {
          _selectedBuildingName = null;
          _buildingSearchController.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _hideBuildingSuggestions();
    _nameController.dispose();
    _phoneController.dispose();
    _phoneDisplayController.dispose();
    _emailController.dispose();
    _buildingSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return ChangeNotifierProvider(
      create: (_) => EditProfileProvider(const ProfileRepository()),
      child: isIOS ? _buildIOSScreen() : _buildAndroidScreen(),
    );
  }

  Widget _buildIOSScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Builder(
          builder: (builderContext) => Column(
            children: [
              // Header
              _buildIOSHeader(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        SizedBox(height: 20),
                        // Profile Picture Section
                        Consumer<EditProfileProvider>(
                          builder: (context, editProfileProvider, child) =>
                              _buildProfilePictureSection(
                                isIOS: true,
                                editProfileProvider: editProfileProvider,
                              ),
                        ),
                        SizedBox(height: 40),
                        // Name Field
                        _buildNameField(isIOS: true),
                        SizedBox(height: 24),
                        // Phone Field
                        _buildPhoneField(isIOS: true),
                        SizedBox(height: 24),
                        // Email Field
                        _buildEmailField(isIOS: true),
                        // Contact Save Button (shows when phone or email is being edited)
                        if (_isEditingPhone || _isEditingEmail) ...[
                          SizedBox(height: 12),
                          Builder(
                            builder: (context) => _buildSaveFieldButton(
                              text: 'SAVE',
                              onPressed: () => _handleContactSave(context),
                              isIOS: true,
                            ),
                          ),
                        ],
                        SizedBox(height: 24),
                        // Building ID Field
                        _buildBuildingIdField(isIOS: true),
                        SizedBox(height: 40),
                        // Save Button
                        Builder(
                          builder: (context) => _buildSaveButton(
                            isIOS: true,
                            onSave: () {
                              if (kDebugMode) {
                                print(
                                  '🔵 [EditProfileScreen] Save button tapped (iOS)',
                                );
                              }
                              _handleSave(context);
                            },
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Builder(
          builder: (builderContext) => Column(
            children: [
              // Header
              _buildAndroidHeader(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        SizedBox(height: 20),
                        // Profile Picture Section
                        Consumer<EditProfileProvider>(
                          builder: (context, editProfileProvider, child) =>
                              _buildProfilePictureSection(
                                isIOS: false,
                                editProfileProvider: editProfileProvider,
                              ),
                        ),
                        SizedBox(height: 40),
                        // Name Field
                        _buildNameField(isIOS: false),
                        SizedBox(height: 24),
                        // Phone Field
                        _buildPhoneField(isIOS: false),
                        SizedBox(height: 24),
                        // Email Field
                        _buildEmailField(isIOS: false),
                        // Contact Save Button (shows when phone or email is being edited)
                        if (_isEditingPhone || _isEditingEmail) ...[
                          SizedBox(height: 12),
                          Builder(
                            builder: (context) => _buildSaveFieldButton(
                              text: 'SAVE',
                              onPressed: () => _handleContactSave(context),
                              isIOS: false,
                            ),
                          ),
                        ],
                        SizedBox(height: 24),
                        // Building ID Field
                        _buildBuildingIdField(isIOS: false),
                        SizedBox(height: 40),
                        // Save Button
                        Builder(
                          builder: (context) => _buildSaveButton(
                            isIOS: false,
                            onSave: () {
                              if (kDebugMode) {
                                print(
                                  '🔵 [EditProfileScreen] Save button tapped (Android)',
                                );
                              }
                              _handleSave(context);
                            },
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOSHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          StandardBackButton(onPressed: () => Navigator.pop(context)),
          Expanded(
            child: Text(
              'EDIT PROFILE',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAndroidHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          StandardBackButton(onPressed: () => Navigator.pop(context)),
          Expanded(
            child: Text(
              'EDIT PROFILE',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection({
    required bool isIOS,
    required EditProfileProvider editProfileProvider,
  }) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final photoUrl = user?.photo;

    // Show selected image if available, otherwise show network image or avatar icon
    Widget imageWidget;
    if (_selectedImageFile != null) {
      imageWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      imageWidget = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: 60, color: Colors.white);
        },
      );
    } else {
      // Show avatar icon when image is null
      imageWidget = Icon(Icons.person, size: 60, color: Colors.white);
    }

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipOval(child: imageWidget),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              text: 'CHANGE',
              color: AppTheme.primaryColor,
              onPressed: () => _pickImage(isIOS),
              isIOS: isIOS,
            ),
            SizedBox(width: 16),
            _buildActionButton(
              text: editProfileProvider.isSaving ? 'SAVING...' : 'SAVE',
              color: const Color(0xFF04CDFE),
              onPressed:
                  _selectedImageFile != null && !editProfileProvider.isSaving
                  ? () => _saveProfileImage(
                      editProfileProvider: editProfileProvider,
                    )
                  : () {}, // Empty function if disabled
              isIOS: isIOS,
              isEnabled:
                  _selectedImageFile != null && !editProfileProvider.isSaving,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(bool isIOS) async {
    if (!mounted) return;

    // Show action sheet/dialog to choose between camera and gallery
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text('Select Image Source'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.camera, isIOS);
              },
              child: Text('Camera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.gallery, isIOS);
              },
              child: Text('Photo Library'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: Text('Cancel'),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera, isIOS);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery, isIOS);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _pickImageFromSource(ImageSource source, bool isIOS) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      if (mounted) {
        final isIOSPlatform = Theme.of(context).platform == TargetPlatform.iOS;
        if (isIOSPlatform) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Failed to pick image: ${e.toString()}'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to pick image: ${e.toString()}'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    }
  }

  Future<void> _saveProfileImage({
    required EditProfileProvider editProfileProvider,
  }) async {
    if (_selectedImageFile == null) return;

    final authProvider = context.read<AuthProvider>();

    final success = await editProfileProvider.uploadProfileImage(
      authProvider: authProvider,
      filePath: _selectedImageFile!.path,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedImageFile =
            null; // Clear selected image after successful upload
      });

      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Success'),
            content: Text('Profile image updated successfully'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } else {
      final error =
          editProfileProvider.error ?? 'Failed to update profile image';
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text(error),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required bool isIOS,
    bool isEnabled = true,
  }) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: isEnabled ? color : color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(isIOS ? 20 : 12),
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isEnabled ? onPressed : null,
              child: Text(
                text,
                style: AppTheme.bebasNeue(
                  color: isEnabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isEnabled ? onPressed : null,
                child: Center(
                  child: Text(
                    text,
                    style: AppTheme.bebasNeue(
                      color: isEnabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabelWithAsterisk(String label) {
    if (label.contains('*')) {
      final parts = label.split('*');
      return RichText(
        text: TextSpan(
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
          children: [
            TextSpan(text: parts[0]),
            const TextSpan(
              text: '*',
              style: TextStyle(color: Color(0xFF04CDFE)),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      label,
      style: AppTheme.bebasNeue(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNameField({required bool isIOS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabelWithAsterisk('NAME *'),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingName = !_isEditingName;
                });
              },
              child: Text(
                _isEditingName ? 'CANCEL' : 'EDIT',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          enabled: _isEditingName,
          isIOS: isIOS,
        ),
      ],
    );
  }

  Widget _buildPhoneField({required bool isIOS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabelWithAsterisk('PHONE *'),
            GestureDetector(
              onTap: () {
                setState(() {
                  // If cancelling edit, restore original value
                  if (_isEditingPhone) {
                    _isEditingPhone = false;
                    _loadUserData();
                  } else {
                    _isEditingPhone = true;
                  }
                  _syncPhoneDisplay();
                });
              },
              child: Text(
                _isEditingPhone ? 'CANCEL' : 'EDIT',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildPhoneFieldWithCountryCode(isIOS: isIOS),
      ],
    );
  }

  List<CountryCode> _getAllCountryCodes() {
    // List of common country codes matching the CountryCodePicker
    return [
      const CountryCode(
        name: 'United Arab Emirates',
        code: 'AE',
        dialCode: '+971',
        flag: '🇦🇪',
      ),
      const CountryCode(
        name: 'Saudi Arabia',
        code: 'SA',
        dialCode: '+966',
        flag: '🇸🇦',
      ),
      const CountryCode(
        name: 'Kuwait',
        code: 'KW',
        dialCode: '+965',
        flag: '🇰🇼',
      ),
      const CountryCode(
        name: 'Qatar',
        code: 'QA',
        dialCode: '+974',
        flag: '🇶🇦',
      ),
      const CountryCode(
        name: 'Bahrain',
        code: 'BH',
        dialCode: '+973',
        flag: '🇧🇭',
      ),
      const CountryCode(
        name: 'Oman',
        code: 'OM',
        dialCode: '+968',
        flag: '🇴🇲',
      ),
      const CountryCode(
        name: 'India',
        code: 'IN',
        dialCode: '+91',
        flag: '🇮🇳',
      ),
      const CountryCode(
        name: 'United States',
        code: 'US',
        dialCode: '+1',
        flag: '🇺🇸',
      ),
      const CountryCode(
        name: 'United Kingdom',
        code: 'GB',
        dialCode: '+44',
        flag: '🇬🇧',
      ),
      const CountryCode(
        name: 'Canada',
        code: 'CA',
        dialCode: '+1',
        flag: '🇨🇦',
      ),
      const CountryCode(
        name: 'Australia',
        code: 'AU',
        dialCode: '+61',
        flag: '🇦🇺',
      ),
      const CountryCode(
        name: 'Pakistan',
        code: 'PK',
        dialCode: '+92',
        flag: '🇵🇰',
      ),
      const CountryCode(
        name: 'Bangladesh',
        code: 'BD',
        dialCode: '+880',
        flag: '🇧🇩',
      ),
      const CountryCode(
        name: 'Philippines',
        code: 'PH',
        dialCode: '+63',
        flag: '🇵🇭',
      ),
      const CountryCode(
        name: 'Egypt',
        code: 'EG',
        dialCode: '+20',
        flag: '🇪🇬',
      ),
      const CountryCode(
        name: 'Jordan',
        code: 'JO',
        dialCode: '+962',
        flag: '🇯🇴',
      ),
      const CountryCode(
        name: 'Lebanon',
        code: 'LB',
        dialCode: '+961',
        flag: '🇱🇧',
      ),
      const CountryCode(
        name: 'Turkey',
        code: 'TR',
        dialCode: '+90',
        flag: '🇹🇷',
      ),
    ];
  }

  CountryCode? _findCountryByDialCode(String dialCode) {
    final countries = _getAllCountryCodes();
    try {
      return countries.firstWhere((country) => country.dialCode == dialCode);
    } catch (e) {
      return null; // Return null if not found
    }
  }

  Widget _buildPhoneFieldWithCountryCode({required bool isIOS}) {
    // When NOT editing: show a single disabled field with full phone including +country code
    if (!_isEditingPhone) {
      _syncPhoneDisplay();
      return _buildTextField(
        controller: _phoneDisplayController,
        enabled: false,
        keyboardType: TextInputType.phone,
        hintText: 'PHONE',
        isIOS: isIOS,
      );
    }

    // When editing: show country code picker + editable local phone field
    return Row(
      children: [
        CountryCodePicker(
          onChanged: (country) {
            setState(() {
              _selectedCountryCode = country;
              _syncPhoneDisplay();
            });
          },
          initialSelection: _selectedCountryCode,
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _phoneController,
            enabled: true,
            keyboardType: TextInputType.phone,
            hintText: 'PHONE',
            isIOS: isIOS,
            onChanged: (_) => _syncPhoneDisplay(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField({required bool isIOS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabelWithAsterisk('EMAIL *'),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingEmail = !_isEditingEmail;
                });
              },
              child: Text(
                _isEditingEmail ? 'CANCEL' : 'EDIT',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: _emailController,
          enabled: _isEditingEmail,
          keyboardType: TextInputType.emailAddress,
          isIOS: isIOS,
        ),
      ],
    );
  }

  Widget _buildBuildingIdField({required bool isIOS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabelWithAsterisk('BUILDING NAME *'),
            GestureDetector(
              onTap: () {
                if (_isEditingBuilding) {
                  setState(() {
                    _isEditingBuilding = false;
                    // Restore the selected building name if it exists
                    if (_selectedBuildingName != null) {
                      _buildingSearchController.text = _selectedBuildingName!;
                    } else {
                      _buildingSearchController.clear();
                    }
                  });
                  _hideBuildingSuggestions();
                } else {
                  setState(() {
                    _isEditingBuilding = true;
                  });
                  _showBuildingSuggestions(isIOS: isIOS);
                }
              },
              child: Text(
                _isEditingBuilding ? 'CANCEL' : 'EDIT',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        CompositedTransformTarget(
          link: _buildingFieldLink,
          child: _buildTextField(
            controller: _buildingSearchController,
            enabled: _isEditingBuilding,
            hintText: 'Search the building',
            isIOS: isIOS,
            onChanged: (value) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(
                const Duration(milliseconds: 300),
                () async {
                  await context.read<PackageProvider>().searchBuildings(value);
                  if (_isEditingBuilding && mounted) {
                    // Update existing overlay instead of recreating
                    _buildingSuggestionsOverlay?.markNeedsBuild();
                  }
                },
              );
            },
            onTap: () async {
              setState(() {
                _isEditingBuilding = true;
              });
              // Trigger initial search with empty query to show all buildings
              if (_buildingSearchController.text.isEmpty) {
                await context.read<PackageProvider>().searchBuildings('');
              }
              // Show suggestions when field is tapped - will create if doesn't exist
              _showBuildingSuggestions(isIOS: isIOS);
              // Ensure overlay is updated after search
              if (_buildingSuggestionsOverlay != null) {
                _buildingSuggestionsOverlay!.markNeedsBuild();
              }
            },
            suffixIcon: _isEditingBuilding
                ? const Icon(Icons.arrow_drop_down, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  void _showBuildingSuggestions({required bool isIOS}) {
    // If overlay already exists, just mark it for rebuild
    if (_buildingSuggestionsOverlay != null) {
      _buildingSuggestionsOverlay!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth - 40; // 20 padding each side

    _buildingSuggestionsOverlay = OverlayEntry(
      builder: (ctx) {
        return Consumer<PackageProvider>(
          builder: (ctx, provider, _) {
            final results = provider.buildingResults;
            final isSearching = provider.isSearching;

            // Show overlay if searching, has results, or if field is being edited
            // Only hide if not searching, no results, and query is empty and field is not being edited
            if (!isSearching &&
                results.isEmpty &&
                provider.lastQuery.isEmpty &&
                !_isEditingBuilding) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: Stack(
                children: [
                  // Tap outside to hide suggestions
                  Positioned.fill(
                    child: GestureDetector(onTap: _hideBuildingSuggestions),
                  ),
                  // Suggestions dropdown
                  CompositedTransformFollower(
                    link: _buildingFieldLink,
                    showWhenUnlinked: false,
                    offset: const Offset(0, 56),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: maxWidth,
                        constraints: const BoxConstraints(maxHeight: 220),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(isIOS ? 20 : 12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: isSearching && results.isEmpty
                            ? Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : (!isSearching && results.isEmpty)
                            ? Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No buildings found',
                                  style: AppTheme.bebasNeue(
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: results.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                                itemBuilder: (context, index) {
                                  final b = results[index];
                                  return ListTile(
                                    dense: true,
                                    visualDensity: const VisualDensity(
                                      vertical: -2,
                                    ),
                                    title: Text(
                                      b.buildingName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () async {
                                      // Update the text controller immediately
                                      _buildingSearchController.text =
                                          b.buildingName;

                                      // Update providers
                                      context
                                          .read<PackageProvider>()
                                          .selectBuilding(
                                            id: b.id,
                                            name: b.buildingName,
                                          );
                                      // Save building ID to user profile
                                      context
                                          .read<AuthProvider>()
                                          .updateBuildingId(b.id);

                                      // Hide suggestions
                                      _hideBuildingSuggestions();

                                      // Update state after a short delay to ensure overlay is removed
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      if (mounted) {
                                        setState(() {
                                          _selectedBuildingId = b.id;
                                          _selectedBuildingName =
                                              b.buildingName;
                                          _isEditingBuilding = false;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    overlay.insert(_buildingSuggestionsOverlay!);
  }

  void _hideBuildingSuggestions() {
    _buildingSuggestionsOverlay?.remove();
    _buildingSuggestionsOverlay = null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool enabled,
    String? hintText,
    TextInputType? keyboardType,
    required bool isIOS,
    Function(String)? onChanged,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    if (isIOS) {
      return CupertinoTextField(
        controller: controller,
        enabled: enabled,
        placeholder: hintText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        placeholderStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? const Color(0xFF04CDFE)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onChanged: onChanged,
        onTap: onTap,
        suffix: suffixIcon,
      );
    } else {
      return TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: enabled
                  ? const Color(0xFF04CDFE)
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: enabled
                  ? const Color(0xFF04CDFE)
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF04CDFE)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
        ),
        onChanged: onChanged,
        onTap: onTap,
      );
    }
  }

  Widget _buildSaveFieldButton({
    required String text,
    required VoidCallback onPressed,
    required bool isIOS,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF04CDFE),
          borderRadius: BorderRadius.circular(isIOS ? 22 : 12),
        ),
        child: isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressed,
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onPressed,
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSaveButton({required bool isIOS, required VoidCallback onSave}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF04CDFE),
          borderRadius: BorderRadius.circular(isIOS ? 28 : 12),
        ),
        child: isIOS
            ? Consumer<EditProfileProvider>(
                builder: (context, ep, _) => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: ep.isSaving ? null : onSave,
                  child: ep.isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'SAVE',
                          style: AppTheme.bebasNeue(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              )
            : Consumer<EditProfileProvider>(
                builder: (context, ep, _) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: ep.isSaving ? null : onSave,
                    child: Center(
                      child: ep.isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'SAVE',
                              style: AppTheme.bebasNeue(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleContactSave(BuildContext context) async {
    if (kDebugMode) {
      print('🔵 Contact save button pressed');
    }

    final authProvider = context.read<AuthProvider>();
    final ep = context.read<EditProfileProvider>();
    final current = authProvider.user;
    final newEmail = _emailController.text.trim();
    // Combine country code with phone number
    final phoneNumber = _phoneController.text.trim();
    final newPhone = phoneNumber.isNotEmpty
        ? '${_selectedCountryCode.dialCode}$phoneNumber'
        : '';

    if (kDebugMode) {
      print('📧 Current email: ${current?.email}, New email: $newEmail');
      print('📱 Current phone: ${current?.phone}, New phone: $newPhone');
    }

    // Normalize phone numbers for comparison (remove any non-digit characters)
    final currentPhoneStr = current?.phone?.toString() ?? '';
    final normalizedCurrentPhone = currentPhoneStr.replaceAll(
      RegExp(r'\D'),
      '',
    );
    final normalizedNewPhone = newPhone.replaceAll(RegExp(r'\D'), '');

    final emailChanged =
        newEmail.isNotEmpty &&
        newEmail.toLowerCase() != (current?.email?.toLowerCase() ?? '');
    final phoneChanged =
        normalizedNewPhone.isNotEmpty &&
        normalizedNewPhone != normalizedCurrentPhone;

    if (kDebugMode) {
      print('✅ Email changed: $emailChanged, Phone changed: $phoneChanged');
    }

    // If neither field changed, show message and close edit mode
    if (!emailChanged && !phoneChanged) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _isEditingPhone = false;
        _isEditingEmail = false;
      });
      return;
    }

    Future<void> doSaveContact({bool skipPhoneVerification = false}) async {
      try {
        // If phone also changed and we haven't verified it yet, verify phone first
        if (phoneChanged && !skipPhoneVerification) {
          try {
            // Store current route and auth state before making the call
            final routeBeforeCall = ModalRoute.of(context)?.settings.name;
            final wasAuthenticated = authProvider.isAuthenticated;

            final phoneOtp = await authProvider
                .sendPhoneVerificationCodeForProfile(phoneNumber: newPhone);

            // Immediately check if navigation occurred or auth state changed
            if (!mounted) return;

            final routeAfterCall = ModalRoute.of(context)?.settings.name;
            final isStillAuthenticated = authProvider.isAuthenticated;

            // If navigation occurred or user is no longer authenticated, don't proceed
            if (routeBeforeCall != routeAfterCall ||
                routeAfterCall != Routes.customerEditProfile ||
                !isStillAuthenticated ||
                !wasAuthenticated) {
              // Navigation has occurred or auth state changed, don't show dialog or errors
              return;
            }

            if (phoneOtp.isSuccess && phoneOtp.verificationId != null) {
              if (!mounted) return;
              // Verify we're still on the edit profile screen before showing dialog
              final currentRoute = ModalRoute.of(context)?.settings.name;
              if (currentRoute != Routes.customerEditProfile &&
                  currentRoute != null) {
                // Navigation has occurred, don't show dialog
                return;
              }
              // Verify user is still authenticated
              if (!authProvider.isAuthenticated) {
                return;
              }
              // Show OTP dialog instead of full screen navigation
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => EditProfileOtpDialog(
                  phoneNumber: newPhone,
                  otpMethod: 'phone',
                  verificationId: phoneOtp.verificationId,
                  onVerified: () async {
                    await doSaveContact(skipPhoneVerification: true);
                  },
                  onResendPhone: () async {
                    return await authProvider
                        .sendPhoneVerificationCodeForProfile(
                          phoneNumber: newPhone,
                        );
                  },
                ),
              );
              return;
            } else {
              final msg = phoneOtp.errorMessage ?? 'Failed to send phone OTP';
              if (!mounted) return;
              // Check if it's a network error
              if (NetworkErrorUtils.isNetworkErrorString(msg)) {
                NetworkErrorDialog.show(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Colors.red[700],
                  ),
                );
              }
              return;
            }
          } catch (e) {
            if (!mounted) return;
            // Check if it's a network error
            if (NetworkErrorUtils.isNetworkErrorString(e.toString())) {
              NetworkErrorDialog.show(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error sending phone OTP: ${e.toString()}'),
                  backgroundColor: Colors.red[700],
                ),
              );
            }
            return;
          }
        }

        // Save contact details (use original phone format, not normalized)
        final success = await ep.saveProfile(
          authProvider: authProvider,
          phone: phoneChanged ? newPhone : null,
          email: emailChanged ? newEmail : null,
          apartmentName: null, // Apartment name field removed
        );

        if (!mounted) return;

        if (success) {
          setState(() {
            _isEditingPhone = false;
            _isEditingEmail = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact details updated successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        } else {
          final msg = ep.error ?? 'Failed to update contact details';
          // Check if it's a network error
          if (msg == 'NETWORK_ERROR' ||
              NetworkErrorUtils.isNetworkErrorString(msg)) {
            NetworkErrorDialog.show(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }

    // Email OTP verification (if email changed)
    if (emailChanged) {
      try {
        // Store current route and auth state before making the call
        final routeBeforeCall = ModalRoute.of(context)?.settings.name;
        final wasAuthenticated = authProvider.isAuthenticated;

        final result = await authProvider.sendEmailOtp(email: newEmail);

        // Immediately check if navigation occurred or auth state changed
        if (!mounted) return;

        final routeAfterCall = ModalRoute.of(context)?.settings.name;
        final isStillAuthenticated = authProvider.isAuthenticated;

        // If navigation occurred or user is no longer authenticated, don't proceed
        if (routeBeforeCall != routeAfterCall ||
            routeAfterCall != Routes.customerEditProfile ||
            !isStillAuthenticated ||
            !wasAuthenticated) {
          // Navigation has occurred or auth state changed, don't show dialog or errors
          return;
        }

        if (result['success'] == true) {
          if (!mounted) return;
          // Verify we're still on the edit profile screen before showing dialog
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != Routes.customerEditProfile &&
              currentRoute != null) {
            // Navigation has occurred, don't show dialog
            return;
          }
          // Verify user is still authenticated
          if (!authProvider.isAuthenticated) {
            return;
          }
          // Show OTP dialog instead of full screen navigation
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => EditProfileOtpDialog(
              phoneNumber: newEmail,
              otpMethod: 'email',
              email: newEmail,
              onVerified: () async {
                // After email verification, check if phone also needs verification
                await doSaveContact();
              },
              onResendEmail: () async {
                return await authProvider.sendEmailOtp(email: newEmail);
              },
            ),
          );
          return;
        } else {
          final msg = result['message'] ?? 'Failed to send email OTP';
          if (!mounted) return;
          // Check if it's a network error
          if (result['isNetworkError'] == true) {
            NetworkErrorDialog.show(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
            );
          }
          return;
        }
      } catch (e) {
        if (!mounted) return;
        // Check if it's a network error
        if (NetworkErrorUtils.isNetworkErrorString(e.toString())) {
          NetworkErrorDialog.show(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending email OTP: ${e.toString()}'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
        return;
      }
    }

    // Phone OTP verification (if only phone changed, not email)
    if (phoneChanged) {
      await doSaveContact();
      return;
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    try {
      if (kDebugMode) {
        print(
          '🔵 [EditProfileScreen] Save button pressed - _handleSave called',
        );
      }

      final authProvider = context.read<AuthProvider>();
      final ep = context.read<EditProfileProvider>();
      final packageProvider = context.read<PackageProvider>();
      final current = authProvider.user;
      final newEmail = _emailController.text.trim();
      // Combine country code with phone number for proper comparison
      final phoneNumber = _phoneController.text.trim();
      final newPhone = phoneNumber.isNotEmpty
          ? '${_selectedCountryCode.dialCode}$phoneNumber'
          : '';
      // Only check for changes if the field is in edit mode
      // This prevents OTP verification when only country code is changed
      final emailChanged =
          _isEditingEmail &&
          newEmail.isNotEmpty &&
          newEmail.toLowerCase() != (current?.email?.toLowerCase() ?? '');

      // For phone, only check if in edit mode AND the full phone number (with country code) has changed
      // Normalize phone numbers for comparison (remove +, spaces, dashes)
      String normalizePhone(String phone) {
        return phone.replaceAll(RegExp(r'[+\s\-]'), '');
      }

      final currentPhone = current?.phone?.toString() ?? '';
      final normalizedCurrentPhone = normalizePhone(currentPhone);
      final normalizedNewPhone = normalizePhone(newPhone);

      // Only consider phone changed if in edit mode AND the normalized numbers are different
      final phoneChanged =
          _isEditingPhone &&
          newPhone.isNotEmpty &&
          normalizedNewPhone.isNotEmpty &&
          normalizedNewPhone != normalizedCurrentPhone;

      if (kDebugMode) {
        print('📦 [EditProfileScreen] emailChanged: $emailChanged');
        print('📦 [EditProfileScreen] phoneChanged: $phoneChanged');
        print('📦 [EditProfileScreen] _isEditingPhone: $_isEditingPhone');
        print('📦 [EditProfileScreen] currentPhone: $currentPhone');
        print('📦 [EditProfileScreen] newPhone: $newPhone');
        print(
          '📦 [EditProfileScreen] normalizedCurrentPhone: $normalizedCurrentPhone',
        );
        print('📦 [EditProfileScreen] normalizedNewPhone: $normalizedNewPhone');
      }

      // Get building ID from selected building, package provider, or current user
      // Only use a new buildingId if explicitly selected, otherwise preserve existing
      final buildingId =
          _selectedBuildingId ?? packageProvider.selectedBuildingId;
      // If no new building selected, preserve the existing one (don't pass null)
      final buildingIdToSave = buildingId ?? current?.buildingId;

      Future<void> doSave() async {
        if (kDebugMode) {
          print('📦 [EditProfileScreen] doSave() called');
          print(
            '📦 [EditProfileScreen] Building ID to save: $buildingIdToSave',
          );
        }

        final success = await ep.saveProfile(
          authProvider: authProvider,
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          phone: phoneChanged ? newPhone : null,
          email: emailChanged ? newEmail : null,
          buildingId: buildingIdToSave,
          apartmentName: null, // Apartment name field removed
        );

        if (kDebugMode) {
          print('📦 [EditProfileScreen] doSave() completed, success: $success');
        }

        if (!mounted) return;

        if (success) {
          // Update PackageProvider with new building if building was changed
          if (buildingIdToSave != null &&
              buildingIdToSave != current?.buildingId) {
            try {
              // Fetch building name and update PackageProvider
              final repo = const PackageRepository();
              final buildings = await repo.searchBuildings('');
              final building = buildings.firstWhere(
                (b) => b.id == buildingIdToSave,
                orElse: () => BuildingModel(
                  id: buildingIdToSave,
                  buildingName: 'Selected Building',
                ),
              );
              packageProvider.selectBuilding(
                id: buildingIdToSave,
                name: building.buildingName,
              );
            } catch (e) {
              // If building name fetch fails, still update with ID
              packageProvider.selectBuilding(
                id: buildingIdToSave,
                name: 'Selected Building',
              );
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
            // Pop back to Profile screen (Edit Profile was opened from Profile)
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else {
          final msg = ep.error ?? 'Failed to update profile';
          // Check if it's a network error
          if (msg == 'NETWORK_ERROR' ||
              NetworkErrorUtils.isNetworkErrorString(msg)) {
            NetworkErrorDialog.show(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
            );
          }
        }
      }

      // Email OTP verification
      // Only send OTP if email edit button is active AND email has changed
      if (emailChanged && _isEditingEmail) {
        try {
          // Verify user is still authenticated before sending OTP
          if (!authProvider.isAuthenticated) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please log in again to continue'),
                backgroundColor: Colors.red[700],
              ),
            );
            return;
          }

          // Store current route and auth state before making the call
          final routeBeforeCall = ModalRoute.of(context)?.settings.name;
          final wasAuthenticated = authProvider.isAuthenticated;

          final result = await authProvider.sendEmailOtp(email: newEmail);

          // Immediately check if navigation occurred or auth state changed
          if (!mounted) return;

          final routeAfterCall = ModalRoute.of(context)?.settings.name;
          final isStillAuthenticated = authProvider.isAuthenticated;

          // If navigation occurred or user is no longer authenticated, don't proceed
          if (routeBeforeCall != routeAfterCall ||
              routeAfterCall != Routes.customerEditProfile ||
              !isStillAuthenticated ||
              !wasAuthenticated) {
            // Navigation has occurred or auth state changed, don't show dialog or errors
            return;
          }

          if (result['success'] == true) {
            if (!mounted) return;
            // Verify we're still on the edit profile screen before showing dialog
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != Routes.customerEditProfile &&
                currentRoute != null) {
              // Navigation has occurred, don't show dialog
              return;
            }
            // Verify user is still authenticated
            if (!authProvider.isAuthenticated) {
              return;
            }
            // Show OTP dialog instead of full screen navigation
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => EditProfileOtpDialog(
                phoneNumber: newEmail,
                otpMethod: 'email',
                email: newEmail,
                onVerified: () async {
                  await doSave();
                },
                onResendEmail: () async {
                  return await authProvider.sendEmailOtp(email: newEmail);
                },
              ),
            );
          } else {
            final msg = result['message'] ?? 'Failed to send email OTP';
            if (!mounted) return;
            // Double-check we're still on edit profile screen before showing error
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != Routes.customerEditProfile &&
                currentRoute != null) {
              // Navigation has occurred, don't show error
              return;
            }
            // Check if it's a network error
            if (result['isNetworkError'] == true) {
              NetworkErrorDialog.show(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
              );
            }
          }
          return;
        } catch (e) {
          if (!mounted) return;
          // Check if navigation occurred before showing error
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != Routes.customerEditProfile &&
              currentRoute != null) {
            // Navigation has occurred, don't show error
            return;
          }
          // Verify user is still authenticated before showing error
          if (!authProvider.isAuthenticated) {
            // Don't show error if user is no longer authenticated (navigation likely occurred)
            return;
          }
          // Check if it's a network error
          if (NetworkErrorUtils.isNetworkErrorString(e.toString())) {
            NetworkErrorDialog.show(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error sending email OTP: ${e.toString()}'),
                backgroundColor: Colors.red[700],
              ),
            );
          }
          return;
        }
      }

      // Phone OTP verification (Firebase)
      // Only send OTP if phone edit button is active AND phone has changed
      if (phoneChanged && _isEditingPhone) {
        try {
          // Verify user is still authenticated before sending OTP
          if (!authProvider.isAuthenticated) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please log in again to continue'),
                backgroundColor: Colors.red[700],
              ),
            );
            return;
          }

          // Store current route and auth state before making the call
          final routeBeforeCall = ModalRoute.of(context)?.settings.name;
          final wasAuthenticated = authProvider.isAuthenticated;

          final phoneOtp = await authProvider
              .sendPhoneVerificationCodeForProfile(phoneNumber: newPhone);

          // Immediately check if navigation occurred or auth state changed
          if (!mounted) return;

          final routeAfterCall = ModalRoute.of(context)?.settings.name;
          final isStillAuthenticated = authProvider.isAuthenticated;

          // If navigation occurred or user is no longer authenticated, don't proceed
          if (routeBeforeCall != routeAfterCall ||
              routeAfterCall != Routes.customerEditProfile ||
              !isStillAuthenticated ||
              !wasAuthenticated) {
            // Navigation has occurred or auth state changed, don't show dialog or errors
            return;
          }

          if (phoneOtp.isSuccess && phoneOtp.verificationId != null) {
            if (!mounted) return;
            // Verify we're still on the edit profile screen before showing dialog
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != Routes.customerEditProfile &&
                currentRoute != null) {
              // Navigation has occurred, don't show dialog
              return;
            }
            // Verify user is still authenticated
            if (!authProvider.isAuthenticated) {
              return;
            }
            // Show OTP dialog instead of full screen navigation
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => EditProfileOtpDialog(
                phoneNumber: newPhone,
                otpMethod: 'phone',
                verificationId: phoneOtp.verificationId,
                onVerified: () async {
                  await doSave();
                },
                onResendPhone: () async {
                  return await authProvider.sendPhoneVerificationCodeForProfile(
                    phoneNumber: newPhone,
                  );
                },
              ),
            );
          } else {
            final msg = phoneOtp.errorMessage ?? 'Failed to send phone OTP';
            if (!mounted) return;
            // Double-check we're still on edit profile screen before showing error
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != Routes.customerEditProfile &&
                currentRoute != null) {
              // Navigation has occurred, don't show error
              return;
            }
            // Check if it's a network error
            if (NetworkErrorUtils.isNetworkErrorString(msg)) {
              NetworkErrorDialog.show(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
              );
            }
          }
          return;
        } catch (e) {
          if (!mounted) return;
          // Check if navigation occurred before showing error
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != Routes.customerEditProfile &&
              currentRoute != null) {
            // Navigation has occurred, don't show error
            return;
          }
          // Verify user is still authenticated before showing error
          if (!authProvider.isAuthenticated) {
            // Don't show error if user is no longer authenticated (navigation likely occurred)
            return;
          }
          // Check if it's a network error
          if (NetworkErrorUtils.isNetworkErrorString(e.toString())) {
            NetworkErrorDialog.show(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error sending phone OTP: ${e.toString()}'),
                backgroundColor: Colors.red[700],
              ),
            );
          }
          return;
        }
      }

      // No OTP needed - save directly
      if (kDebugMode) {
        print(
          '📦 [EditProfileScreen] No OTP needed, calling doSave() directly',
        );
      }
      await doSave();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [EditProfileScreen] Error in _handleSave: $e');
        print('❌ [EditProfileScreen] Stack trace: $stackTrace');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }
}
