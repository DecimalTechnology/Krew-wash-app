import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../presentation/providers/edit_profile_provider.dart';
import '../../presentation/providers/package_provider.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/package_repository.dart';
import '../../domain/models/building_model.dart';
import '../../../../core/constants/route_constants.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _nameController = TextEditingController();
  final _buildingController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final LayerLink _buildingFieldLink = LayerLink();
  OverlayEntry? _buildingOverlay;
  Timer? _searchDebounce;

  String? _selectedBuildingId;
  String? _selectedBuildingName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phone?.toString() ?? '';
      _emailController.text = user.email ?? '';
      _selectedBuildingId = user.buildingId;

      final packageProvider = context.read<PackageProvider>();
      if (_selectedBuildingId != null) {
        if (packageProvider.selectedBuildingId == _selectedBuildingId &&
            (packageProvider.selectedBuildingName ?? '').isNotEmpty) {
          _selectedBuildingName = packageProvider.selectedBuildingName;
          _buildingController.text = _selectedBuildingName!;
        } else {
          _fetchBuildingName(_selectedBuildingId!);
        }
      }
    }
  }

  Future<void> _fetchBuildingName(String buildingId) async {
    try {
      final repo = const PackageRepository();
      final buildings = await repo.searchBuildings('');
      final building = buildings.firstWhere(
        (b) => b.id == buildingId,
        orElse: () => BuildingModel(id: buildingId, buildingName: ''),
      );
      if (building.buildingName.isNotEmpty && mounted) {
        setState(() {
          _selectedBuildingName = building.buildingName;
          _buildingController.text = building.buildingName;
        });
      }
    } catch (_) {
      // ignore errors; user can search manually
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _buildingOverlay?.remove();
    _nameController.dispose();
    _buildingController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showBuildingSuggestions() {
    if (!mounted) return;
    _buildingOverlay?.remove();
    final overlay = Overlay.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth - 40;

    _buildingOverlay = OverlayEntry(
      builder: (ctx) {
        final provider = Provider.of<PackageProvider>(ctx);
        final results = provider.buildingResults;
        final isSearching = provider.isSearching;

        if (!isSearching && results.isEmpty && provider.lastQuery.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(onTap: _hideBuildingSuggestions),
              ),
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
                      color: const Color(0xFF0B0E1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
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
                                onTap: () {
                                  context
                                      .read<PackageProvider>()
                                      .selectBuilding(
                                        id: b.id,
                                        name: b.buildingName,
                                      );
                                  context.read<AuthProvider>().updateBuildingId(
                                    b.id,
                                  );
                                  setState(() {
                                    _selectedBuildingId = b.id;
                                    _selectedBuildingName = b.buildingName;
                                    _buildingController.text = b.buildingName;
                                  });
                                  _hideBuildingSuggestions();
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

    overlay.insert(_buildingOverlay!);
  }

  void _hideBuildingSuggestions() {
    _buildingOverlay?.remove();
    _buildingOverlay = null;
  }

  Future<void> _handleSave(BuildContext context) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (_selectedBuildingId == null || _selectedBuildingId!.isEmpty) {
      _showError('Please select your building');
      return;
    }
    if (phone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final editProfileProvider = context.read<EditProfileProvider>();

    final success = await editProfileProvider.saveProfile(
      authProvider: authProvider,
      name: name,
      phone: phone,
      email: email,
      buildingId: _selectedBuildingId,
      apartmentName: null, // Apartment name field removed
    );

    if (!mounted) return;

    if (success) {
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Success'),
            content: Text('Profile updated successfully'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.customerHome,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      } else {
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
      final message = editProfileProvider.error ?? 'Failed to update profile';
      _showError(message);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(message),
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
        SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
      );
    }
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text(
          'PROFILE DETAILS',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Builder(
            builder: (builderContext) =>
                _buildForm(builderContext, isIOS: true),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: StandardBackButton(onPressed: () => Navigator.pop(context)),
        ),
        centerTitle: true,
        title: Text(
          'PROFILE DETAILS',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Builder(
            builder: (builderContext) =>
                _buildForm(builderContext, isIOS: false),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isIOS}) {
    final editProfileProvider = context.watch<EditProfileProvider>();

    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NAME *'),
          SizedBox(height: 10),
          _buildTextField(
            controller: _nameController,
            hintText: 'Enter your name',
            isIOS: isIOS,
          ),
          SizedBox(height: 32),

          _buildLabel('BUILDING NAME *'),
          SizedBox(height: 10),
          CompositedTransformTarget(
            link: _buildingFieldLink,
            child: isIOS
                ? CupertinoTextField(
                    controller: _buildingController,
                    placeholder: 'Select your building',
                    style: const TextStyle(color: Colors.white),
                    placeholderStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x8001031C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffix: const Icon(
                      CupertinoIcons.chevron_down,
                      color: Colors.white,
                      size: 20,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedBuildingId = null;
                        _selectedBuildingName = null;
                      });
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 300),
                        () async {
                          await context.read<PackageProvider>().searchBuildings(
                            value,
                          );
                          _showBuildingSuggestions();
                        },
                      );
                    },
                    onTap: () {
                      _showBuildingSuggestions();
                    },
                  )
                : TextField(
                    controller: _buildingController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: const Color(0xFF00D4AA),
                    decoration: _inputDecoration(
                      hintText: 'Select your building',
                      suffixIcon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedBuildingId = null;
                        _selectedBuildingName = null;
                      });
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 300),
                        () async {
                          await context.read<PackageProvider>().searchBuildings(
                            value,
                          );
                          _showBuildingSuggestions();
                        },
                      );
                    },
                    onTap: () {
                      _showBuildingSuggestions();
                    },
                  ),
          ),
          SizedBox(height: 32),

          _buildLabel('PHONE NUMBER *'),
          SizedBox(height: 10),

          _buildTextField(
            controller: _phoneController,
            hintText: '+971',
            keyboardType: TextInputType.phone,
            isIOS: isIOS,
          ),
          SizedBox(height: 32),

          _buildLabel('EMAIL *'),
          SizedBox(height: 10),

          _buildTextField(
            controller: _emailController,
            hintText: 'Enter email',
            keyboardType: TextInputType.emailAddress,
            isIOS: isIOS,
          ),
          SizedBox(height: 40),

          _buildSaveButton(
            context: context,
            editProfileProvider: editProfileProvider,
            isIOS: isIOS,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required bool isIOS,
  }) {
    if (isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: hintText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        placeholderStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        decoration: BoxDecoration(
          color: const Color(0x8001031C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    } else {
      return TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF00D4AA),
        decoration: _inputDecoration(hintText: hintText),
      );
    }
  }

  Widget _buildSaveButton({
    required BuildContext context,
    required EditProfileProvider editProfileProvider,
    required bool isIOS,
  }) {
    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: const Color(0xFF04CDFE),
          borderRadius: BorderRadius.circular(16),
          onPressed: editProfileProvider.isSaving
              ? null
              : () => _handleSave(context),
          child: editProfileProvider.isSaving
              ? const CupertinoActivityIndicator(color: Colors.white)
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
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: editProfileProvider.isSaving
              ? null
              : () => _handleSave(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04CDFE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: editProfileProvider.isSaving
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      filled: true,
      fillColor: const Color(0x8001031C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
