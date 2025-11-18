import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BookingSummaryArguments {
  const BookingSummaryArguments({
    required this.package,
    required this.selectedAddOns,
    required this.selectedDates,
    required this.selectedVehicle,
  });

  final Map<String, dynamic> package;
  final List<Map<String, dynamic>> selectedAddOns;
  final List<DateTime> selectedDates;
  final Map<String, dynamic> selectedVehicle;
}

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key, this.arguments});

  final BookingSummaryArguments? arguments;

  @override
  Widget build(BuildContext context) {
    if (arguments == null) {
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        return CupertinoPageScaffold(
          backgroundColor: Colors.black,
          child: const Center(
            child: Text(
              'Invalid booking data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            'Invalid booking data',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen(context) : _buildAndroidScreen(context);
  }

  Widget _buildIOSScreen(BuildContext context) {
    final package = arguments!.package;
    final addOns = arguments!.selectedAddOns;
    final dates = arguments!.selectedDates;
    final vehicle = arguments!.selectedVehicle;

    // Calculate prices
    final basePrice =
        (package['rawPrice'] as num?)?.toDouble() ??
        double.tryParse(
          package['price']?.toString().replaceAll(' AED', '') ?? '',
        ) ??
        0.0;

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
    final taxRate = 0.10; // 10% tax
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;

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
                    _buildPackageSection(package),
                    if (addOns.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ...addOns.map(
                        (addOn) => _buildAddOnSection(addOn, dates.length),
                      ),
                    ],
                    if (dates.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSelectedDatesSection(dates),
                    ],
                    const SizedBox(height: 24),
                    _buildVehicleSection(vehicle),
                    const SizedBox(height: 24),
                    _buildPriceSummarySection(
                      basePrice,
                      addOns,
                      dates.length,
                      subtotal,
                      taxAmount,
                      total,
                    ),
                    const SizedBox(height: 32),
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
    final package = arguments!.package;
    final addOns = arguments!.selectedAddOns;
    final dates = arguments!.selectedDates;
    final vehicle = arguments!.selectedVehicle;

    // Calculate prices
    final basePrice =
        (package['rawPrice'] as num?)?.toDouble() ??
        double.tryParse(
          package['price']?.toString().replaceAll(' AED', '') ?? '',
        ) ??
        0.0;

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
    final taxRate = 0.10; // 10% tax
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;

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
                    _buildPackageSection(package),
                    if (addOns.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ...addOns.map(
                        (addOn) => _buildAddOnSection(addOn, dates.length),
                      ),
                    ],
                    if (dates.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSelectedDatesSection(dates),
                    ],
                    const SizedBox(height: 24),
                    _buildVehicleSection(vehicle),
                    const SizedBox(height: 24),
                    _buildPriceSummarySection(
                      basePrice,
                      addOns,
                      dates.length,
                      subtotal,
                      taxAmount,
                      total,
                    ),
                    const SizedBox(height: 32),
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
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'BOOKING SUMMARY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF04CDFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'BOOKING SUMMARY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            packageName,
            style: const TextStyle(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addOnName,
            style: const TextStyle(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
        const Text(
          'SELECTED DATES',
          style: TextStyle(
            color: Color(0xFF04CDFE),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dates.map((date) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECTED VEHICLE',
            style: TextStyle(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            model,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
    double taxAmount,
    double total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRICE SUMMARY',
            style: TextStyle(
              color: Color(0xFF04CDFE),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(
            'MONTHLY WASH (BASE)',
            '${basePrice.toStringAsFixed(0)} AED',
          ),
          if (addOns.isNotEmpty) ...[
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            _buildPriceRow(
              'ADD-ON TOTAL',
              '${addOnTotal(addOns, dateCount).toStringAsFixed(0)} AED',
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
          ],
          _buildPriceRow('SUBTOTAL', '${subtotal.toStringAsFixed(0)} AED'),
          const SizedBox(height: 8),
          _buildPriceRow(
            'TAX & FEE (10%)',
            '${taxAmount.toStringAsFixed(0)} AED',
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
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
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white70,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
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
            color: Colors.black.withOpacity(0.3),
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
            // TODO: Navigate to payment screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proceeding to payment...')),
            );
          },
          child: const Text(
            'CONFIRM & PROCEED TO PAYMENT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
            color: Colors.black.withOpacity(0.3),
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
            // TODO: Navigate to payment screen
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Proceeding to payment...'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
          child: const Text(
            'CONFIRM & PROCEED TO PAYMENT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
}
