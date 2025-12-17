import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/edit_profile_provider.dart';
import '../../../auth/presentation/screens/otp_verification_screen.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
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
      _phoneController.text = user.phone?.toString() ?? '';
      _emailController.text = user.email ?? '';

      // Load building ID from user data if available
      if (user.buildingId != null && user.buildingId!.isNotEmpty) {
        _selectedBuildingId = user.buildingId;
        // Fetch building name to display in the field
        _fetchBuildingName(user.buildingId!);
      }
    }
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
      // Try multiple search strategies to find the building
      final repo = const PackageRepository();
      List<BuildingModel> buildings = [];

      // Strategy 1: Try searching with building ID (in case API supports ID search)
      try {
        buildings = await repo.searchBuildings(buildingId);
        final building = buildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () => BuildingModel(id: buildingId, buildingName: ''),
        );
        if (building.buildingName.isNotEmpty) {
          if (mounted) {
            setState(() {
              _selectedBuildingName = building.buildingName;
              _buildingSearchController.text = building.buildingName;
            });
          }
          return;
        }
      } catch (_) {
        // Continue to next strategy
      }

      // Strategy 2: Try searching with common characters to get all buildings
      // Try 'a' first (most common starting letter)
      try {
        buildings = await repo.searchBuildings('a');
        var building = buildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () => BuildingModel(id: buildingId, buildingName: ''),
        );
        if (building.buildingName.isEmpty) {
          // Try 'e' if 'a' didn't work
          buildings = await repo.searchBuildings('e');
          building = buildings.firstWhere(
            (b) => b.id == buildingId,
            orElse: () => BuildingModel(id: buildingId, buildingName: ''),
          );
        }
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _selectedBuildingName = building.buildingName;
            _buildingSearchController.text = building.buildingName;
          });
          return;
        }
      } catch (_) {
        // Continue to next strategy
      }

      // Strategy 3: Try empty search (might return all buildings)
      try {
        buildings = await repo.searchBuildings('');
        final building = buildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () => BuildingModel(id: buildingId, buildingName: ''),
        );
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _selectedBuildingName = building.buildingName;
            _buildingSearchController.text = building.buildingName;
          });
          return;
        }
      } catch (_) {
        // If all strategies fail, show building ID
      }

      // If all strategies fail, at least show the building ID
      if (mounted) {
        setState(() {
          _buildingSearchController.text = buildingId;
        });
      }
    } catch (e) {
      // Log error for debugging
      if (kDebugMode) {
        print('Error fetching building name: $e');
      }
      // If fetching fails, at least show the building ID
      if (mounted) {
        setState(() {
          _buildingSearchController.text = buildingId;
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

    // Show selected image if available, otherwise show network image or default
    Widget imageWidget;
    if (_selectedImageFile != null) {
      imageWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      imageWidget = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/CustomerProfile/image1.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/CustomerProfile/image1.png',
        fit: BoxFit.cover,
      );
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
              color: const Color(0xFF00D4AA),
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
            backgroundColor: Color(0xFF00D4AA),
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

  Widget _buildNameField({required bool isIOS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NAME',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
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
            Text(
              'PHONE',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingPhone = !_isEditingPhone;
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
        _buildTextField(
          controller: _phoneController,
          enabled: _isEditingPhone,
          keyboardType: TextInputType.phone,
          isIOS: isIOS,
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
            Text(
              'EMAIL',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
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
            Text(
              'BUILDING NAME',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
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
            hintText: 'SELECT YOUR BUILDING',
            isIOS: isIOS,
            onChanged: (value) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(
                const Duration(milliseconds: 300),
                () async {
                  await context.read<PackageProvider>().searchBuildings(value);
                  if (_isEditingBuilding) {
                    _showBuildingSuggestions(isIOS: isIOS);
                  }
                },
              );
            },
            onTap: () {
              setState(() {
                _isEditingBuilding = true;
              });
              // Show suggestions when field is tapped
              _showBuildingSuggestions(isIOS: isIOS);
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
    _buildingSuggestionsOverlay?.remove();

    final overlay = Overlay.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth - 40; // 20 padding each side

    _buildingSuggestionsOverlay = OverlayEntry(
      builder: (ctx) {
        final provider = Provider.of<PackageProvider>(ctx);
        final results = provider.buildingResults;
        final isSearching = provider.isSearching;

        // Hide overlay if not searching, no results, and query is empty
        if (!isSearching && results.isEmpty && provider.lastQuery.isEmpty) {
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
                              style: AppTheme.bebasNeue(color: Colors.white70),
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
                                  style: const TextStyle(color: Colors.white),
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
                                  context.read<AuthProvider>().updateBuildingId(
                                    b.id,
                                  );

                                  // Hide suggestions
                                  _hideBuildingSuggestions();

                                  // Update state after a short delay to ensure overlay is removed
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _selectedBuildingId = b.id;
                                      _selectedBuildingName = b.buildingName;
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
    final newPhone = _phoneController.text.trim();

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
          final phoneOtp = await authProvider.sendPhoneVerificationCode(
            phoneNumber: newPhone,
          );
          if (phoneOtp.isSuccess && phoneOtp.verificationId != null) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  phoneNumber: newPhone,
                  otpMethod: 'phone',
                  verificationId: phoneOtp.verificationId,
                  isSignUp: false,
                  onVerified: () async {
                    await doSaveContact(skipPhoneVerification: true);
                  },
                ),
              ),
            );
            return;
          } else {
            final msg = phoneOtp.errorMessage ?? 'Failed to send phone OTP';
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
            );
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
              backgroundColor: Color(0xFF00D4AA),
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
        final result = await authProvider.sendEmailOtp(email: newEmail);
        if (result['success'] == true) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: newEmail,
                otpMethod: 'email',
                email: newEmail,
                isSignUp: false,
                onVerified: () async {
                  // After email verification, check if phone also needs verification
                  await doSaveContact();
                },
              ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email OTP: ${e.toString()}'),
            backgroundColor: Colors.red[700],
          ),
        );
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
      final newPhone = _phoneController.text.trim();
      final emailChanged =
          newEmail.isNotEmpty && newEmail != (current?.email ?? '');
      final phoneChanged =
          newPhone.isNotEmpty &&
          newPhone != ((current?.phone?.toString()) ?? '');

      if (kDebugMode) {
        print('📦 [EditProfileScreen] emailChanged: $emailChanged');
        print('📦 [EditProfileScreen] phoneChanged: $phoneChanged');
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
          phone: newPhone.isEmpty ? null : newPhone,
          email: newEmail.isEmpty ? null : newEmail,
          buildingId: buildingIdToSave,
          apartmentName: null, // Apartment name field removed
        );

        if (kDebugMode) {
          print('📦 [EditProfileScreen] doSave() completed, success: $success');
        }

        if (!mounted) return;

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Color(0xFF00D4AA),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.customerHome,
              (route) => false,
            );
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
      if (emailChanged) {
        final result = await authProvider.sendEmailOtp(email: newEmail);
        if (result['success'] == true) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: newEmail,
                otpMethod: 'email',
                email: newEmail,
                isSignUp: false,
                onVerified: () async {
                  await doSave();
                },
              ),
            ),
          );
          return;
        } else {
          final msg = result['message'] ?? 'Failed to send email OTP';
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
          );
          return;
        }
      }

      // Phone OTP verification (Firebase)
      if (phoneChanged) {
        final phoneOtp = await authProvider.sendPhoneVerificationCode(
          phoneNumber: newPhone,
        );
        if (phoneOtp.isSuccess && phoneOtp.verificationId != null) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: newPhone,
                otpMethod: 'phone',
                verificationId: phoneOtp.verificationId,
                isSignUp: false,
                onVerified: () async {
                  await doSave();
                },
              ),
            ),
          );
          return;
        } else {
          final msg = phoneOtp.errorMessage ?? 'Failed to send phone OTP';
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
          );
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
