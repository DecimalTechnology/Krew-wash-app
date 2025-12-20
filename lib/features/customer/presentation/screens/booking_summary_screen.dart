import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../../core/services/secure_storage_service.dart';
import 'payment_screen.dart';

class BookingSummaryArguments {
  const BookingSummaryArguments({
    this.package,
    required this.selectedAddOns,
    required this.selectedDates,
    required this.selectedVehicle,
  });

  final Map<String, dynamic>? package;
  final List<Map<String, dynamic>> selectedAddOns;
  final List<DateTime> selectedDates;
  final Map<String, dynamic> selectedVehicle;
}

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key, this.arguments});

  final BookingSummaryArguments? arguments;

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Clear pending booking only when app is being closed/terminated.
    if (state == AppLifecycleState.detached) {
      SecureStorageService.clearPendingBooking();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _clearPendingBookingAndPop(BuildContext context) async {
    await SecureStorageService.clearPendingBooking();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.arguments == null) {
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        return CupertinoPageScaffold(
          backgroundColor: Colors.black,
          child: Center(
            child: Text(
              'Invalid booking data',
              style: AppTheme.bebasNeue(color: Colors.white),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Invalid booking data',
            style: AppTheme.bebasNeue(color: Colors.white),
          ),
        ),
      );
    }

    // Validate that either package or add-ons are present
    final package = widget.arguments!.package;
    final addOns = widget.arguments!.selectedAddOns;
    if (package == null && addOns.isEmpty) {
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        return CupertinoPageScaffold(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Column(
              children: [
                _buildIOSHeader(context),
                Expanded(
                  child: Center(
                    child: Text(
                      'Please select a package or add-on',
                      style: AppTheme.bebasNeue(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: Text(
                    'Please select a package or add-on',
                    style: AppTheme.bebasNeue(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await SecureStorageService.clearPendingBooking();
        }
      },
      child: isIOS ? _buildIOSScreen(context) : _buildAndroidScreen(context),
    );
  }

  Widget _buildIOSScreen(BuildContext context) {
    final package = widget.arguments!.package;
    final addOns = widget.arguments!.selectedAddOns;
    final dates = widget.arguments!.selectedDates;
    final vehicle = widget.arguments!.selectedVehicle;

    // Calculate prices
    final basePrice = package != null
        ? ((package['rawPrice'] as num?)?.toDouble() ??
            double.tryParse(
              package['price']?.toString().replaceAll(' AED', '') ?? '',
            ) ??
            0.0)
        : 0.0;

    double addOnTotal = 0.0;
    for (final addOn in addOns) {
      final addOnPrice =
          (addOn['rawPrice'] as num?)?.toDouble() ??
          double.tryParse(
            addOn['price']?.toString().replaceAll(' AED', '') ?? '',
          ) ??
          0.0;
      final multiplier = dates.isEmpty ? 1 : dates.length;
      addOnTotal += addOnPrice * multiplier;
    }

    final subtotal = basePrice + addOnTotal;
    final total = subtotal;

    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            _buildIOSHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (package != null) _buildPackageSection(package),
                    if (addOns.isNotEmpty) ...[
                      SizedBox(height: 20),
                      ...addOns.map(
                        (addOn) => _buildAddOnSection(addOn, dates.length),
                      ),
                    ],
                    if (dates.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildSelectedDatesSection(dates),
                    ],
                    SizedBox(height: 24),
                    _buildVehicleSection(vehicle),
                    SizedBox(height: 24),
                    _buildPriceSummarySection(
                      basePrice,
                      addOns,
                      dates.length,
                      subtotal,
                      total,
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildIOSConfirmButton(context, total),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidScreen(BuildContext context) {
    final package = widget.arguments!.package;
    final addOns = widget.arguments!.selectedAddOns;
    final dates = widget.arguments!.selectedDates;
    final vehicle = widget.arguments!.selectedVehicle;

    // Calculate prices
    final basePrice = package != null
        ? ((package['rawPrice'] as num?)?.toDouble() ??
            double.tryParse(
              package['price']?.toString().replaceAll(' AED', '') ?? '',
            ) ??
            0.0)
        : 0.0;

    double addOnTotal = 0.0;
    for (final addOn in addOns) {
      final addOnPrice =
          (addOn['rawPrice'] as num?)?.toDouble() ??
          double.tryParse(
            addOn['price']?.toString().replaceAll(' AED', '') ?? '',
          ) ??
          0.0;
      final multiplier = dates.isEmpty ? 1 : dates.length;
      addOnTotal += addOnPrice * multiplier;
    }

    final subtotal = basePrice + addOnTotal;
    final total = subtotal;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (package != null) _buildPackageSection(package),
                    if (addOns.isNotEmpty) ...[
                      SizedBox(height: 20),
                      ...addOns.map(
                        (addOn) => _buildAddOnSection(addOn, dates.length),
                      ),
                    ],
                    if (dates.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildSelectedDatesSection(dates),
                    ],
                    SizedBox(height: 24),
                    _buildVehicleSection(vehicle),
                    SizedBox(height: 24),
                    _buildPriceSummarySection(
                      basePrice,
                      addOns,
                      dates.length,
                      subtotal,
                      total,
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildConfirmButton(context, total),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          StandardBackButton(
            onPressed: () => _clearPendingBookingAndPop(context),
          ),
          Expanded(
            child: Text(
              'BOOKING SUMMARY',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(width: 40), // Balance the back button width
        ],
      ),
    );
  }

  Widget _buildIOSHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          StandardBackButton(
            onPressed: () => _clearPendingBookingAndPop(context),
          ),
          Expanded(
            child: Text(
              'BOOKING SUMMARY',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(width: 40), // Balance the back button width
        ],
      ),
    );
  }

  Widget _buildPackageSection(Map<String, dynamic> package) {
    final packageName = (package['name'] ?? 'MONTHLY WASH')
        .toString()
        .toUpperCase();
    final description =
        package['description']?.toString() ??
        'THIS IS BASE PACKAGE, WHICH INCLUDE 8 TIME WASH PER MONTH.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            packageName,
            style: AppTheme.bebasNeue(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnSection(Map<String, dynamic> addOn, int dateCount) {
    final addOnName = (addOn['name'] ?? 'ADD-ONS INTERIOR CLEANING')
        .toString()
        .toUpperCase();
    final description =
        addOn['description']?.toString() ??
        'WE PROVIDE PROFESSIONAL CAR INTERIOR VACUUM CLEANING.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addOnName,
            style: AppTheme.bebasNeue(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDatesSection(List<DateTime> dates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECTED DATES',
          style: AppTheme.bebasNeue(
            color: Color(0xFF04CDFE),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dates.map((date) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(date),
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVehicleSection(Map<String, dynamic> vehicle) {
    final model =
        vehicle['vehicleModel']?.toString().toUpperCase() ?? 'VEHICLE';
    final type = vehicle['type']?.toString().toUpperCase() ?? '--';
    final number = vehicle['vehicleNumber']?.toString().toUpperCase() ?? '--';
    final color = vehicle['color']?.toString().toUpperCase() ?? '--';
    final parking = vehicle['parkingNumber']?.toString().toUpperCase() ?? '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECTED VEHICLE',
            style: AppTheme.bebasNeue(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 12),
          Text(
            model,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          _buildVehicleInfoRow('TYPE', type),
          _buildVehicleInfoRow('NUMBER', number),
          _buildVehicleInfoRow('COLOR', color),
          _buildVehicleInfoRow('PARKING NUMBER', parking),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bebasNeue(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummarySection(
    double basePrice,
    List<Map<String, dynamic>> addOns,
    int dateCount,
    double subtotal,
    double total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRICE SUMMARY',
            style: AppTheme.bebasNeue(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 16),
          _buildPriceRow(
            'MONTHLY WASH (BASE)',
            '${basePrice.toStringAsFixed(0)} AED',
          ),
          if (addOns.isNotEmpty) ...[
            SizedBox(height: 12),
            ...addOns.map((addOn) {
              final addOnPrice =
                  (addOn['rawPrice'] as num?)?.toDouble() ??
                  double.tryParse(
                    addOn['price']?.toString().replaceAll(' AED', '') ?? '',
                  ) ??
                  0.0;
              final addOnName = (addOn['name'] ?? 'ADD-ON')
                  .toString()
                  .toUpperCase();
              final dateText = dateCount > 0
                  ? 'X $dateCount DAYS X 1 VEHICLE'
                  : 'X 1 VEHICLE';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPriceRow(
                  '$addOnName',
                  '${addOnPrice.toStringAsFixed(0)} AED $dateText',
                  isSecondary: true,
                ),
              );
            }),
            SizedBox(height: 8),
            _buildPriceRow(
              'ADD-ON TOTAL',
              '${addOnTotal(addOns, dateCount).toStringAsFixed(0)} AED',
            ),
            SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            SizedBox(height: 12),
          ],
          _buildPriceRow(
            'TOTAL',
            '${total.toStringAsFixed(0)} AED',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isSecondary = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTheme.bebasNeue(
              color: isTotal ? Colors.white : Colors.white70,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: AppTheme.bebasNeue(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04CDFE),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _navigateToPayment(context, total);
          },
          child: Text(
            'CONFIRM & PROCEED TO PAYMENT',
            style: AppTheme.bebasNeue(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSConfirmButton(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: const Color(0xFF04CDFE),
          borderRadius: BorderRadius.circular(12),
          onPressed: () {
            _navigateToPayment(context, total);
          },
          child: Text(
            'CONFIRM & PROCEED TO PAYMENT',
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  double addOnTotal(List<Map<String, dynamic>> addOns, int dateCount) {
    double total = 0.0;
    for (final addOn in addOns) {
      final addOnPrice =
          (addOn['rawPrice'] as num?)?.toDouble() ??
          double.tryParse(
            addOn['price']?.toString().replaceAll(' AED', '') ?? '',
          ) ??
          0.0;
      total += addOnPrice * dateCount;
    }
    return total;
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final day = date.day;
    final month = monthNames[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  void _navigateToPayment(BuildContext context, double total) {
    if (widget.arguments == null) {
      return;
    }

    final package = widget.arguments!.package;
    final addOns = widget.arguments!.selectedAddOns;
    final dates = widget.arguments!.selectedDates;
    final vehicle = widget.arguments!.selectedVehicle;

    // LOG SELECTED VEHICLE DETAILS
    print('═══════════════════════════════════════════════════════════');
    print('🚗 [BookingSummary] SELECTED VEHICLE DETAILS');
    print('═══════════════════════════════════════════════════════════');
    print('📦 Full vehicle object: $vehicle');
    print('📦 Vehicle keys: ${vehicle.keys.toList()}');
    print('📦 Vehicle _id: ${vehicle['_id']}');
    print('📦 Vehicle id: ${vehicle['id']}');
    print('📦 Vehicle vehicleId: ${vehicle['vehicleId']}');
    print('📦 Vehicle vehicle_id: ${vehicle['vehicle_id']}');
    print('📦 Vehicle userId: ${vehicle['userId']}');
    print('📦 Vehicle type: ${vehicle['type']}');
    print('📦 Vehicle vehicleModel: ${vehicle['vehicleModel']}');
    print('📦 Vehicle vehicleNumber: ${vehicle['vehicleNumber']}');
    print('📦 All vehicle values: ${vehicle.values.toList()}');
    print('═══════════════════════════════════════════════════════════');

    // Prepare booking data
    final bookingData = {
      'package': package,
      'addOns': addOns,
      'dates': dates.map((d) => d.toIso8601String()).toList(),
      'vehicle': vehicle,
      'totalAmount': total,
    };

    try {
      Navigator.pushNamed(
        context,
        Routes.customerPayment,
        arguments: PaymentScreenArguments(
          amount: total,
          currency: 'AED',
          bookingData: bookingData,
          package: package,
          selectedAddOns: addOns,
          selectedDates: dates,
          selectedVehicle: vehicle,
        ),
      );
    } catch (e) {
      // Error handling - navigation failed
    }
  }
}
