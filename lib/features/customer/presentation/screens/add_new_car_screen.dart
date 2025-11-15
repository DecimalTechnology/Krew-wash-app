import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/vehicle_repository.dart';
import '../../presentation/providers/vehicle_provider.dart';

class AddNewCarScreen extends StatelessWidget {
  const AddNewCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleProvider(repository: const VehicleRepository())
        ..loadVehicleTypes()
        ..loadVehicles(),
      child: const _AddNewCarView(),
    );
  }
}

class _AddNewCarView extends StatefulWidget {
  const _AddNewCarView();

  @override
  State<_AddNewCarView> createState() => _AddNewCarViewState();
}

class _AddNewCarViewState extends State<_AddNewCarView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _parkingNumberController =
      TextEditingController();
  final TextEditingController _parkingAreaController = TextEditingController();

  final FocusNode _carTypeFocusNode = FocusNode();
  final FocusNode _vehicleModelFocusNode = FocusNode();

  final LayerLink _carTypeFieldLink = LayerLink();
  final LayerLink _vehicleModelFieldLink = LayerLink();

  final GlobalKey _carTypeFieldKey = GlobalKey();
  final GlobalKey _vehicleModelFieldKey = GlobalKey();

  OverlayEntry? _carTypeOverlayEntry;
  OverlayEntry? _vehicleModelOverlayEntry;

  String _carTypeQuery = '';
  String _vehicleModelQuery = '';

  Timer? _carTypeDebounce;
  Timer? _vehicleModelDebounce;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _carTypeFocusNode.addListener(() {
      if (_carTypeFocusNode.hasFocus) {
        final provider = context.read<VehicleProvider>();
        if (provider.vehicleTypes.isEmpty && !provider.isLoadingVehicleTypes) {
          provider.loadVehicleTypes(forceRefresh: true);
        }
        _carTypeQuery = _carTypeController.text.trim().toLowerCase();
        _showCarTypeOverlay();
      } else {
        _carTypeDebounce?.cancel();
        _hideCarTypeOverlay();
      }
    });

    _vehicleModelFocusNode.addListener(() async {
      if (_vehicleModelFocusNode.hasFocus) {
        final provider = context.read<VehicleProvider>();
        final selectedTypeId = provider.selectedVehicleTypeId;
        if (selectedTypeId == null || selectedTypeId.isEmpty) {
          _vehicleModelFocusNode.unfocus();
          _showSnack('Please select a car type first');
          return;
        }
        if (provider.vehicleModels.isEmpty &&
            !provider.isLoadingVehicleModels) {
          await provider.loadVehicleModelsForType(selectedTypeId);
        }
        _vehicleModelQuery = _vehicleModelController.text.trim().toLowerCase();
        _showVehicleModelOverlay();
      } else {
        _vehicleModelDebounce?.cancel();
        _hideVehicleModelOverlay();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VehicleProvider>();
      provider.loadVehicleTypes();
      provider.loadVehicles();
    });
  }

  @override
  void dispose() {
    _carTypeDebounce?.cancel();
    _vehicleModelDebounce?.cancel();
    _hideCarTypeOverlay();
    _hideVehicleModelOverlay();
    _carTypeFocusNode.dispose();
    _vehicleModelFocusNode.dispose();

    _carTypeController.dispose();
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    _colorController.dispose();
    _parkingNumberController.dispose();
    _parkingAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final selectedTypeName = vehicleProvider.selectedVehicleTypeName ?? '';
    if (_carTypeController.text != selectedTypeName) {
      _carTypeController.text = selectedTypeName;
    }

    final selectedModelName = vehicleProvider.selectedVehicleModel ?? '';
    if (_vehicleModelController.text != selectedModelName) {
      _vehicleModelController.text = selectedModelName;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _buildForm(context, vehicleProvider, isIOS),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    VehicleProvider vehicleProvider,
    bool isIOS,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildCarTypeField(vehicleProvider),
          const SizedBox(height: 20),
          _buildVehicleModelField(vehicleProvider),
          const SizedBox(height: 28),
          _buildLabeledField(
            label: 'VEHICLE NUMBER *',
            controller: _vehicleNumberController,
            hintText: 'Enter vehicle number',
            validator: (value) => (value == null || value.isEmpty)
                ? 'Enter vehicle number'
                : null,
          ),
          const SizedBox(height: 18),
          _buildLabeledField(
            label: 'COLOR *',
            controller: _colorController,
            hintText: 'Enter vehicle color',
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter color' : null,
          ),
          const SizedBox(height: 18),
          _buildLabeledField(
            label: 'PARKING NUMBER *',
            controller: _parkingNumberController,
            hintText: 'Enter parking number',
            validator: (value) => (value == null || value.isEmpty)
                ? 'Enter parking number'
                : null,
          ),
          const SizedBox(height: 18),
          _buildLabeledField(
            label: 'PARKING AREA *',
            controller: _parkingAreaController,
            hintText: 'Enter parking area',
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter parking area' : null,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _handleSave(vehicleProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04CDFE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF04CDFE),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF04CDFE).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 15),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCarTypeField(VehicleProvider provider) {
    final isLoading = provider.isLoadingVehicleTypes;
    final hasSelection =
        provider.selectedVehicleTypeId != null ||
        _carTypeController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAR TYPE *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _carTypeFieldLink,
          child: TextFormField(
            key: _carTypeFieldKey,
            controller: _carTypeController,
            focusNode: _carTypeFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hintText: isLoading
                  ? 'Loading car types...'
                  : 'Search or select your car type',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasSelection)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      tooltip: 'Clear selection',
                      onPressed: () {
                        _carTypeDebounce?.cancel();
                        _vehicleModelDebounce?.cancel();
                        _carTypeController.clear();
                        _vehicleModelController.clear();
                        _carTypeQuery = '';
                        _vehicleModelQuery = '';
                        provider.clearVehicleSelection();
                        _hideCarTypeOverlay();
                        _hideVehicleModelOverlay();
                        setState(() {});
                        _carTypeFocusNode.requestFocus();
                        _showCarTypeOverlay();
                      },
                    ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white70),
                ],
              ),
            ),
            onChanged: (value) {
              _carTypeDebounce?.cancel();
              _carTypeDebounce = Timer(const Duration(milliseconds: 120), () {
                _carTypeQuery = value.trim().toLowerCase();
                _carTypeOverlayEntry?.markNeedsBuild();
              });
            },
            validator: (_) => provider.selectedVehicleTypeId == null
                ? 'Select a car type'
                : null,
            onTap: () {
              if (!_carTypeFocusNode.hasFocus) {
                _carTypeFocusNode.requestFocus();
              }
              _showCarTypeOverlay();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleModelField(VehicleProvider provider) {
    final hasTypeSelected = provider.selectedVehicleTypeId != null;
    final isLoading = provider.isLoadingVehicleModels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VEHICLE MODEL *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _vehicleModelFieldLink,
          child: TextFormField(
            key: _vehicleModelFieldKey,
            controller: _vehicleModelController,
            focusNode: _vehicleModelFocusNode,
            style: const TextStyle(color: Colors.white),
            readOnly: !hasTypeSelected,
            decoration: _inputDecoration(
              hintText: !hasTypeSelected
                  ? 'Select car type first'
                  : (isLoading
                        ? 'Loading car models...'
                        : 'Search or select your car model'),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: hasTypeSelected ? Colors.white70 : Colors.white30,
              ),
            ),
            onChanged: (value) {
              _vehicleModelDebounce?.cancel();
              _vehicleModelDebounce = Timer(
                const Duration(milliseconds: 120),
                () {
                  _vehicleModelQuery = value.trim().toLowerCase();
                  _vehicleModelOverlayEntry?.markNeedsBuild();
                },
              );
            },
            validator: (_) => provider.selectedVehicleModel == null
                ? 'Select a car model'
                : null,
            onTap: () {
              if (!hasTypeSelected) {
                _showSnack('Please select a car type first');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            hintText: hintText ?? '',
            suffixIcon: suffixIcon,
          ),
          validator: validator,
          onTap: () {
            if (readOnly) {
              FocusScope.of(context).unfocus();
            }
            if (onTap != null) {
              onTap();
            }
          },
        ),
      ],
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
      fillColor: const Color(0xFF0B0E1F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF04CDFE), width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _handleSave(VehicleProvider vehicleProvider) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicleTypeId = vehicleProvider.selectedVehicleTypeId;
    if (vehicleTypeId == null || vehicleTypeId.isEmpty) {
      _showSnack('Please select a car type');
      return;
    }

    final vehicleModel =
        vehicleProvider.selectedVehicleModel ??
        _vehicleModelController.text.trim();
    if (vehicleModel.isEmpty) {
      _showSnack('Please select a car model');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await vehicleProvider.createVehicle(
        vehicleNumber: _vehicleNumberController.text.trim(),
        color: _colorController.text.trim(),
        vehicleModel: vehicleModel,
        parkingNumber: _parkingNumberController.text.trim(),
        parkingArea: _parkingAreaController.text.trim(),
      );

      if (!mounted) return;

      final success = response['success'] == true;
      final message =
          (response['message'] ??
                  (success
                      ? 'Vehicle created successfully'
                      : 'Failed to save vehicle'))
              .toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? const Color(0xFF00D4AA) : Colors.redAccent,
        ),
      );

      if (success) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orangeAccent),
    );
  }

  void _showCarTypeOverlay() {
    if (!mounted) return;
    _carTypeOverlayEntry?.remove();
    _carTypeOverlayEntry = OverlayEntry(
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<VehicleProvider>(),
          child: Builder(
            builder: (overlayContext) {
              final providerWatcher = overlayContext.watch<VehicleProvider>();
              final isLoading = providerWatcher.isLoadingVehicleTypes;
              final List<Map<String, String>> results;
              if (_carTypeQuery.isEmpty) {
                results = providerWatcher.vehicleTypes;
              } else {
                results = providerWatcher.vehicleTypes
                    .where(
                      (type) => (type['name'] ?? '').toLowerCase().contains(
                        _carTypeQuery,
                      ),
                    )
                    .toList();
              }

              final renderBox =
                  _carTypeFieldKey.currentContext?.findRenderObject()
                      as RenderBox?;
              final width =
                  renderBox?.size.width ?? MediaQuery.of(ctx).size.width;

              return Positioned.fill(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _hideCarTypeOverlay,
                      ),
                    ),
                    CompositedTransformFollower(
                      link: _carTypeFieldLink,
                      showWhenUnlinked: false,
                      offset: const Offset(0, 56),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: width,
                          constraints: const BoxConstraints(maxHeight: 240),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11172B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : results.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No car types found',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
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
                                    final item = results[index];
                                    final name = item['name'] ?? '';
                                    final isSelected =
                                        providerWatcher.selectedVehicleTypeId ==
                                        item['id'];
                                    return ListTile(
                                      dense: true,
                                      visualDensity: const VisualDensity(
                                        vertical: -2,
                                      ),
                                      title: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Color(0xFF04CDFE),
                                            )
                                          : null,
                                      onTap: () async {
                                        final id = item['id'];
                                        final typeName = item['name'];
                                        if (id == null || typeName == null) {
                                          return;
                                        }
                                        _carTypeController.text = typeName;
                                        _carTypeQuery = typeName.toLowerCase();
                                        _vehicleModelController.clear();
                                        _vehicleModelQuery = '';
                                        await providerWatcher.selectVehicleType(
                                          id: id,
                                          name: typeName,
                                        );
                                        _hideCarTypeOverlay();
                                        _carTypeFocusNode.unfocus();
                                        _vehicleModelFocusNode.requestFocus();
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
          ),
        );
      },
    );

    Overlay.of(context).insert(_carTypeOverlayEntry!);
  }

  void _hideCarTypeOverlay() {
    _carTypeOverlayEntry?.remove();
    _carTypeOverlayEntry = null;
  }

  void _showVehicleModelOverlay() {
    if (!mounted) return;
    final provider = context.read<VehicleProvider>();
    if (provider.selectedVehicleTypeId == null) {
      return;
    }

    _vehicleModelOverlayEntry?.remove();
    _vehicleModelOverlayEntry = OverlayEntry(
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Builder(
            builder: (overlayContext) {
              final providerWatcher = overlayContext.watch<VehicleProvider>();
              final isLoading = providerWatcher.isLoadingVehicleModels;
              final List<String> results;
              if (_vehicleModelQuery.isEmpty) {
                results = providerWatcher.vehicleModels;
              } else {
                results = providerWatcher.vehicleModels
                    .where(
                      (model) =>
                          model.toLowerCase().contains(_vehicleModelQuery),
                    )
                    .toList();
              }

              final renderBox =
                  _vehicleModelFieldKey.currentContext?.findRenderObject()
                      as RenderBox?;
              final width =
                  renderBox?.size.width ?? MediaQuery.of(ctx).size.width;

              return Positioned.fill(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _hideVehicleModelOverlay,
                      ),
                    ),
                    CompositedTransformFollower(
                      link: _vehicleModelFieldLink,
                      showWhenUnlinked: false,
                      offset: const Offset(0, 56),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: width,
                          constraints: const BoxConstraints(maxHeight: 240),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11172B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : results.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No car models found',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
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
                                    final model = results[index];
                                    final isSelected =
                                        providerWatcher.selectedVehicleModel ==
                                        model;
                                    return ListTile(
                                      dense: true,
                                      visualDensity: const VisualDensity(
                                        vertical: -2,
                                      ),
                                      title: Text(
                                        model,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Color(0xFF04CDFE),
                                            )
                                          : null,
                                      onTap: () {
                                        providerWatcher.selectVehicleModel(
                                          model,
                                        );
                                        _vehicleModelController.text = model;
                                        _vehicleModelQuery = model
                                            .toLowerCase();
                                        _hideVehicleModelOverlay();
                                        _vehicleModelFocusNode.unfocus();
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
          ),
        );
      },
    );

    Overlay.of(context).insert(_vehicleModelOverlayEntry!);
  }

  void _hideVehicleModelOverlay() {
    _vehicleModelOverlayEntry?.remove();
    _vehicleModelOverlayEntry = null;
  }
}
