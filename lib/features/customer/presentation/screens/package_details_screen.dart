import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/vehicle_repository.dart';
import '../../presentation/providers/vehicle_provider.dart';
import '../../../../core/constants/route_constants.dart';
import 'booking_summary_screen.dart';

class PackageDetailsArguments {
  const PackageDetailsArguments({
    this.package,
    this.selectedAddOns = const [],
    this.buildingName,
    this.vehicleTypeName,
  });

  final Map<String, dynamic>? package;
  final List<Map<String, dynamic>> selectedAddOns;
  final String? buildingName;
  final String? vehicleTypeName;
}

class PackageDetailsScreen extends StatelessWidget {
  const PackageDetailsScreen({super.key, this.arguments});

  final PackageDetailsArguments? arguments;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          VehicleProvider(repository: const VehicleRepository())
            ..loadVehicles(),
      child: _PackageDetailsView(arguments: arguments),
    );
  }
}

class _PackageDetailsView extends StatefulWidget {
  const _PackageDetailsView({this.arguments});

  final PackageDetailsArguments? arguments;

  @override
  State<_PackageDetailsView> createState() => _PackageDetailsViewState();
}

class _PackageDetailsViewState extends State<_PackageDetailsView> {
  static const List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final ScrollController _scrollController = ScrollController();

  List<DateTime> _selectedDates = [];
  String? _selectedVehicleId;

  Map<String, dynamic>? get _package => widget.arguments?.package;
  List<Map<String, dynamic>> get _selectedAddOns =>
      widget.arguments?.selectedAddOns ?? [];
  bool get _requiresDates => _selectedAddOns.isNotEmpty;

  Future<void> _pickDates() async {
    final tempSelection = _selectedDates.map(_normalize).toSet();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11162A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Wash Dates',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) {
                        final normalized = _normalize(date);
                        setModalState(() {
                          if (tempSelection.contains(normalized)) {
                            tempSelection.remove(normalized);
                          } else {
                            tempSelection.add(normalized);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempSelection.isEmpty
                            ? [
                                const Text(
                                  'No dates selected yet.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ]
                            : tempSelection
                                  .map(
                                    (date) => Chip(
                                      label: Text(
                                        _formatDate(date),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF04CDFE),
                                      deleteIconColor: Colors.white,
                                      onDeleted: () {
                                        setModalState(() {
                                          tempSelection.remove(date);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                            ),
                            onPressed: () {
                              setModalState(tempSelection.clear);
                            },
                            child: const Text('CLEAR'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF04CDFE),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              setState(() {
                                _selectedDates = tempSelection.toList()..sort();
                              });
                            },
                            child: const Text('DONE'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) {
    final weekday = _weekdayNames[(date.weekday - 1).clamp(0, 6).toInt()];
    final month = _monthNames[(date.month - 1).clamp(0, 11).toInt()];
    return '$weekday, $month ${date.day}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (_package != null) _buildPackageCard(_package!),
              if (_selectedAddOns.isNotEmpty) ...[
                const SizedBox(height: 20),
                ..._selectedAddOns.map(_buildAddOnCard),
              ],
              if (_requiresDates) ...[
                const SizedBox(height: 24),
                _buildDateSelector(),
              ],
              const SizedBox(height: 24),
              _buildVehicleSection(),
              const SizedBox(height: 32),
              _buildCheckoutButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        const Text(
          'MY PACKAGE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        if (widget.arguments?.vehicleTypeName != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0x3304CDFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.arguments!.vehicleTypeName!.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF04CDFE),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final features = _extractFeatures(package);
    final price = package['price']?.toString() ?? '';
    final frequency = package['frequency']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF01031C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04CDFE).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04CDFE).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (package['name'] ?? 'PACKAGE').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF04CDFE),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      package['description']?.toString() ??
                          'Premium car wash package',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    frequency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF04CDFE),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'FEATURES',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF04CDFE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractFeatures(Map<String, dynamic> source) {
    if (source['features'] is List) {
      return List<String>.from(source['features'] as List)
          .map((item) => item.toString())
          .where((feature) => feature.trim().isNotEmpty)
          .toList();
    }
    final description = source['description']?.toString() ?? '';
    if (description.contains('•')) {
      return description
          .split('•')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return description.isNotEmpty ? [description] : [];
  }

  Widget _buildAddOnCard(Map<String, dynamic> addOn) {
    final features = _extractFeatures(addOn);
    final singlePriceLabel = addOn['price']?.toString() ?? '0 AED';
    final rawPrice =
        (addOn['rawPrice'] as num?)?.toDouble() ??
        double.tryParse(addOn['price']?.toString() ?? '') ??
        0;
    final multiplier = _selectedDates.isEmpty ? 1 : _selectedDates.length;
    final totalPrice = rawPrice * multiplier;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF01061C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04CDFE).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (addOn['name'] ?? 'ADD-ON').toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF04CDFE),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addOn['frequency']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
              Text(
                singlePriceLabel,
                style: const TextStyle(
                  color: Color(0xFF04CDFE),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF04CDFE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EACH SERVICE',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    singlePriceLabel,
                    style: const TextStyle(
                      color: Color(0xFF04CDFE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SELECTED DAYS: $multiplier',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    '${totalPrice.toStringAsFixed(2)} AED',
                    style: const TextStyle(
                      color: Color(0xFF04CDFE),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT DATES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04CDFE),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _pickDates,
          child: const Text('SELECT DATES'),
        ),
        const SizedBox(height: 12),
        if (_selectedDates.isEmpty)
          const Text(
            'No dates selected yet.',
            style: TextStyle(color: Colors.white54),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedDates
                .map(
                  (date) => Chip(
                    label: Text(
                      _formatDate(date),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: const Color(0x3304CDFE),
                    deleteIconColor: Colors.white,
                    onDeleted: () {
                      setState(() {
                        _selectedDates = _selectedDates
                            .where((d) => d != date)
                            .toList();
                      });
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    final normalizedPackageType = (widget.arguments?.vehicleTypeName ?? '')
        .toLowerCase()
        .trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SELECT YOUR VEHICLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  Routes.customerAddNewCar,
                );
                if (!mounted) return;
                if (result == true) {
                  await context.read<VehicleProvider>().loadVehicles();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add, color: Color(0xFF04CDFE)),
              label: const Text(
                'ADD',
                style: TextStyle(color: Color(0xFF04CDFE)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<VehicleProvider>(
          builder: (context, provider, _) {
            final vehicles = provider.vehicles;
            if (vehicles.isEmpty && provider.isLoadingVehicles) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(color: Color(0xFF04CDFE)),
                ),
              );
            }
            if (vehicles.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No vehicles found. Please add a car to proceed.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }
            final filteredVehicles = normalizedPackageType.isEmpty
                ? vehicles
                : vehicles.where((vehicle) {
                    final type =
                        vehicle['type']?.toString().toLowerCase() ?? '';
                    return type.contains(normalizedPackageType);
                  }).toList();

            if (filteredVehicles.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No ${widget.arguments?.vehicleTypeName ?? ''} vehicles found. Please add a matching vehicle.',
                  style: const TextStyle(color: Colors.white54),
                ),
              );
            }

            if (_selectedVehicleId == null ||
                !filteredVehicles.any(
                  (vehicle) => vehicle['_id']?.toString() == _selectedVehicleId,
                )) {
              _selectedVehicleId = filteredVehicles.first['_id']?.toString();
            }

            return Column(
              children: filteredVehicles.map((vehicle) {
                final vehicleId = vehicle['_id']?.toString();
                final isSelected =
                    vehicleId != null &&
                    vehicleId.isNotEmpty &&
                    vehicleId == _selectedVehicleId;
                final number = vehicle['vehicleNumber']?.toString() ?? '--';
                final type = vehicle['type']?.toString() ?? '--';
                final color = vehicle['color']?.toString() ?? '--';
                final parking = vehicle['parkingNumber']?.toString() ?? '--';

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVehicleId = vehicleId;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050A1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF04CDFE)
                            : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle['vehicleModel']?.toString() ?? 'VEHICLE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildVehicleInfoRow('TYPE', type),
                        _buildVehicleInfoRow('NUMBER', number),
                        _buildVehicleInfoRow('COLOR', color),
                        _buildVehicleInfoRow('PARKING NUMBER', parking),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVehicleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    final requiresDates = _requiresDates;
    final hasDates = _selectedDates.isNotEmpty;
    final isEnabled =
        _selectedVehicleId != null && (!requiresDates || hasDates);
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, _) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? const Color(0xFF04CDFE)
                : Colors.grey[800],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isEnabled
              ? () {
                  final vehicles = vehicleProvider.vehicles;
                  final selectedVehicle = vehicles.firstWhere(
                    (vehicle) =>
                        vehicle['_id']?.toString() == _selectedVehicleId,
                    orElse: () => <String, dynamic>{},
                  );

                  if (selectedVehicle.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a vehicle')),
                    );
                    return;
                  }

                  if (_package == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Package information is missing'),
                      ),
                    );
                    return;
                  }

                  // Use selected dates or empty list if not required
                  final datesToUse = requiresDates
                      ? _selectedDates
                      : <DateTime>[];

                  Navigator.pushNamed(
                    context,
                    Routes.customerBookingSummary,
                    arguments: BookingSummaryArguments(
                      package: _package!,
                      selectedAddOns: _selectedAddOns,
                      selectedDates: datesToUse,
                      selectedVehicle: selectedVehicle,
                    ),
                  );
                }
              : null,
          child: const Text(
            'CHECKOUT',
            style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
