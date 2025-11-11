import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class ChooseSlotScreen extends StatefulWidget {
  const ChooseSlotScreen({super.key});

  @override
  State<ChooseSlotScreen> createState() => _ChooseSlotScreenState();
}

class _ChooseSlotScreenState extends State<ChooseSlotScreen> {
  String? selectedDate;
  List<String> selectedSlots = [
    '10AM - 11AM',
    '2PM - 3PM',
    '3PM - 4PM',
    '4PM - 5PM',
  ]; // Pre-selected slots as shown in design

  final List<String> timeSlots = [
    '10AM - 11AM',
    '11AM - 12PM',
    '12PM - 1PM',
    '2PM - 3PM',
    '3PM - 4PM',
    '4PM - 5PM',
    '5PM - 6PM',
    '6PM - 7PM',
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isTablet = screenWidth > 600;

    if (Platform.isIOS) {
      return _buildIOSScreen(context, isLargeScreen, isTablet);
    } else {
      return _buildAndroidScreen(context, isLargeScreen, isTablet);
    }
  }

  Widget _buildIOSScreen(
    BuildContext context,
    bool isLargeScreen,
    bool isTablet,
  ) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Fixed Background Image
          _buildBackgroundImage(),

          // Scrollable Content
          CustomScrollView(
            slivers: [
              // Sliver App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                expandedHeight: 0,
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                flexibleSpace: _buildSliverHeader(true),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 100),

                    // Date Selection
                    _buildDateSelection(),

                    // Time Slots Grid
                    _buildTimeSlotsGrid(),

                    // Book Button
                    _buildBookButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidScreen(
    BuildContext context,
    bool isLargeScreen,
    bool isTablet,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fixed Background Image
          _buildBackgroundImage(),

          // Scrollable Content
          CustomScrollView(
            slivers: [
              // Sliver App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                expandedHeight: 0,
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                flexibleSpace: _buildSliverHeader(false),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 200),

                    // Date Selection
                    _buildDateSelection(),

                    // Time Slots Grid
                    _buildTimeSlotsGrid(),

                    // Book Button
                    _buildBookButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(child: _buildHeaderContent(isIOS)),
    );
  }

  Widget _buildHeaderContent(bool isIOS) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF04CDFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 300,
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/ChooseSlot/porashe.png'),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOSHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button - Teal geometric shape
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),
          // "slot" text in top-left
          const Text(
            'slot',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Profile Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.person,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button - Teal geometric shape
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          // "slot" text in top-left
          const Text(
            'slot',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Profile Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      child: const Text(
        'CHOOSE YOUR SLOT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHOOSE THE DATE*',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF04CDFE), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate ?? 'Select Date',
                    style: TextStyle(
                      color: selectedDate != null ? Colors.white : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE TIME SLOTS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final slot = timeSlots[index];
              final isSelected = selectedSlots.contains(slot);

              return GestureDetector(
                onTap: () => _toggleSlot(slot),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Dark grey for unselected
                    border: Border.all(
                      width: 1,
                      color: isSelected ? Color(0xFF04CDFE) : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      // Arrow icon in top left corner
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: isSelected ? Colors.white : Colors.grey[400],
                          size: 18,
                        ),
                      ),
                      // Clock icon and time text on the left side
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: isSelected
                                  ? Colors.blue[400]
                                  : Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              slot,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.blue[400]
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: ElevatedButton(
        onPressed: selectedDate != null && selectedSlots.isNotEmpty
            ? _bookSlot
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04CDFE),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF04CDFE).withValues(alpha: 0.3),
        ),
        child: Text(
          'BOOK YOUR SLOT',
          style: TextStyle(
            color: selectedDate != null && selectedSlots.isNotEmpty
                ? Colors.white
                : Colors.grey[400]!,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF04CDFE),
              onPrimary: Colors.white,
              surface: Color(0xFF01031C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _toggleSlot(String slot) {
    setState(() {
      if (selectedSlots.contains(slot)) {
        selectedSlots.remove(slot);
      } else {
        selectedSlots.add(slot);
      }
    });
  }

  void _bookSlot() {
    // Handle booking logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Slot booked for ${selectedDate} at ${selectedSlots.join(', ')}',
        ),
        backgroundColor: const Color(0xFF04CDFE),
      ),
    );
  }
}
