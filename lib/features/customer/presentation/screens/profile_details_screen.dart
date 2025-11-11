import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _apartmentController = TextEditingController();
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
    _apartmentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showBuildingSuggestions() {
    _buildingOverlay?.remove();
    final overlay = Overlay.of(context);
    if (overlay == null) return;

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
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
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
    final apartment = _apartmentController.text.trim();
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
    if (apartment.isEmpty) {
      _showError('Please enter your apartment number');
      return;
    }
    if (phone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final editProfileProvider = context.read<EditProfileProvider>();

    final success = await editProfileProvider.saveProfile(
      authProvider: authProvider,
      name: name,
      phone: phone,
      email: email.isEmpty ? null : email,
      buildingId: _selectedBuildingId,
      apartmentName: apartment,
    );

    if (!mounted) return;

    if (success) {
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
    } else {
      final message = editProfileProvider.error ?? 'Failed to update profile';
      _showError(message);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileProvider(const ProfileRepository()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'PROFILE DETAILS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: _buildForm(context),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final editProfileProvider = context.watch<EditProfileProvider>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NAME'),
          _buildTextField(
            controller: _nameController,
            hintText: 'Enter your name',
          ),
          const SizedBox(height: 18),

          _buildLabel('BUILDING NAME *'),
          const SizedBox(height: 8),
          CompositedTransformTarget(
            link: _buildingFieldLink,
            child: TextField(
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
          const SizedBox(height: 18),

          _buildLabel('APARTMENT NUMBER *'),
          _buildTextField(
            controller: _apartmentController,
            hintText: 'Enter apartment number',
          ),
          const SizedBox(height: 18),

          _buildLabel('PHONE NUMBER *'),
          _buildTextField(
            controller: _phoneController,
            hintText: '+971',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),

          _buildLabel('EMAIL'),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 30),

          SizedBox(
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      cursorColor: const Color(0xFF00D4AA),
      decoration: _inputDecoration(hintText: hintText),
    );
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
