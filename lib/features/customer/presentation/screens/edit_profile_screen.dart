import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/edit_profile_provider.dart';
import '../../../auth/presentation/screens/otp_verification_screen.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../presentation/providers/package_provider.dart';
import '../../../../core/constants/route_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _apartmentNameController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phone?.toString() ?? '';
      _emailController.text = user.email ?? '';

      // Load building ID from user data if available
      if (user.buildingId != null) {
        _selectedBuildingId = user.buildingId;
        // Note: We don't have the building name, so the field will be empty
        // User can search and select to see the building name
      }

      // Load apartment name from user data if available
      // (assuming it's stored in user model, adjust field name as needed)
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _hideBuildingSuggestions();
    _nameController.dispose();
    _apartmentNameController.dispose();
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
        child: Column(
          children: [
            // Header
            _buildIOSHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Picture Section
                    _buildProfilePictureSection(isIOS: true),
                    const SizedBox(height: 40),
                    // Name Field
                    _buildNameField(isIOS: true),
                    const SizedBox(height: 24),
                    // Apartment Name Field
                    _buildApartmentNameField(isIOS: true),
                    const SizedBox(height: 24),
                    // Phone Field
                    _buildPhoneField(isIOS: true),
                    const SizedBox(height: 24),
                    // Email Field
                    _buildEmailField(isIOS: true),
                    // Contact Save Button (shows when phone or email is being edited)
                    if (_isEditingPhone || _isEditingEmail) ...[
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) => _buildSaveFieldButton(
                          text: 'SAVE',
                          onPressed: () => _handleContactSave(context),
                          isIOS: true,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Building ID Field
                    _buildBuildingIdField(isIOS: true),
                    const SizedBox(height: 40),
                    // Save Button
                    Builder(
                      builder: (context) => _buildSaveButton(
                        isIOS: true,
                        onSave: () => _handleSave(context),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildAndroidHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Picture Section
                    _buildProfilePictureSection(isIOS: false),
                    const SizedBox(height: 40),
                    // Name Field
                    _buildNameField(isIOS: false),
                    const SizedBox(height: 24),
                    // Apartment Name Field
                    _buildApartmentNameField(isIOS: false),
                    const SizedBox(height: 24),
                    // Phone Field
                    _buildPhoneField(isIOS: false),
                    const SizedBox(height: 24),
                    // Email Field
                    _buildEmailField(isIOS: false),
                    // Contact Save Button (shows when phone or email is being edited)
                    if (_isEditingPhone || _isEditingEmail) ...[
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) => _buildSaveFieldButton(
                          text: 'SAVE',
                          onPressed: () => _handleContactSave(context),
                          isIOS: false,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Building ID Field
                    _buildBuildingIdField(isIOS: false),
                    const SizedBox(height: 40),
                    // Save Button
                    Builder(
                      builder: (context) => _buildSaveButton(
                        isIOS: false,
                        onSave: () => _handleSave(context),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'EDIT PROFILE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAndroidHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'EDIT PROFILE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection({required bool isIOS}) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final photoUrl = user?.photo;

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            image: photoUrl != null && photoUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage('assets/CustomerProfile/image1.png'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              text: 'CHANGE',
              color: const Color(0xFF00D4AA),
              onPressed: () {
                // TODO: Implement image picker
              },
              isIOS: isIOS,
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              text: 'SAVE',
              color: const Color(0xFF04CDFE),
              onPressed: () {
                // TODO: Implement save image
              },
              isIOS: isIOS,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required bool isIOS,
  }) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 12),
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
            const Text(
              'NAME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          enabled: _isEditingName,
          isIOS: isIOS,
        ),
      ],
    );
  }

  Widget _buildApartmentNameField({required bool isIOS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APARTMENT NAME',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _apartmentNameController,
          enabled: true,
          isIOS: isIOS,
        ),
        const SizedBox(height: 12),
        _buildSaveFieldButton(
          text: 'SAVE',
          onPressed: () {
            // TODO: Save apartment name
          },
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
            const Text(
              'PHONE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 12),
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
            const Text(
              'EMAIL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 12),
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
            const Text(
              'BUILDING ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 12),
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
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: isSearching && results.isEmpty
                        ? const Padding(
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
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No buildings found',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: results.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.white.withOpacity(0.08),
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
        placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? const Color(0xFF04CDFE)
                : Colors.white.withOpacity(0.3),
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
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: enabled
                  ? const Color(0xFF04CDFE)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: enabled
                  ? const Color(0xFF04CDFE)
                  : Colors.white.withOpacity(0.3),
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
                    fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
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
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onSave,
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onSave,
                  child: Consumer<EditProfileProvider>(
                    builder: (context, ep, _) => Center(
                      child: ep.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'SAVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
          );
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
    final authProvider = context.read<AuthProvider>();
    final ep = context.read<EditProfileProvider>();
    final packageProvider = context.read<PackageProvider>();
    final current = authProvider.user;
    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final emailChanged =
        newEmail.isNotEmpty && newEmail != (current?.email ?? '');
    final phoneChanged =
        newPhone.isNotEmpty && newPhone != ((current?.phone?.toString()) ?? '');

    // Get building ID from selected building, package provider, or current user
    // Only use a new buildingId if explicitly selected, otherwise preserve existing
    final buildingId =
        _selectedBuildingId ?? packageProvider.selectedBuildingId;
    // If no new building selected, preserve the existing one (don't pass null)
    final buildingIdToSave = buildingId ?? current?.buildingId;

    Future<void> doSave() async {
      final success = await ep.saveProfile(
        authProvider: authProvider,
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        phone: newPhone.isEmpty ? null : newPhone,
        email: newEmail.isEmpty ? null : newEmail,
        buildingId: buildingIdToSave,
        apartmentName: _apartmentNameController.text.trim().isEmpty
            ? null
            : _apartmentNameController.text.trim(),
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
        );
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

    // No OTP needed
    await doSave();
  }
}
