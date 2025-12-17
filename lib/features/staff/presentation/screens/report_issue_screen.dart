import 'package:carwash_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../domain/models/booking_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'issue_chat_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  final CleanerBooking booking;

  const ReportIssueScreen({super.key, required this.booking});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? _selectedIssueType;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _issueTypes = [
    'VEHICLE NOT FOUND',
    'INCORRECT LOCATION',
    'ACCESS DENIED',
    'VEHICLE LOCKED',
    'CUSTOMER REFUSED',
    'OTHERS',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _selectedIssueType != null ||
        _descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildContent(isIOS: true),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(isIOS: false),
    );
  }

  Widget _buildContent({required bool isIOS}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(context, isIOS, isSmallScreen, horizontalPadding),
          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  // Issue Type Section
                  _buildIssueTypeSection(isIOS, isSmallScreen),
                  SizedBox(height: 32),
                  // Description Section
                  _buildDescriptionSection(isIOS, isSmallScreen),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Submit Button
          _buildSubmitButton(context, isIOS, isSmallScreen, horizontalPadding),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back button
          StandardBackButton(onPressed: () => Navigator.of(context).pop()),
          const Spacer(),
          // Centered heading
          Text(
            'REPORT ISSUE',
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          // Invisible placeholder to balance the back button
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildIssueTypeSection(bool isIOS, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ISSUE TYPE',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16),
        ..._issueTypes.map((issueType) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildIssueTypeButton(issueType, isIOS, isSmallScreen),
          );
        }),
      ],
    );
  }

  Widget _buildIssueTypeButton(
    String issueType,
    bool isIOS,
    bool isSmallScreen,
  ) {
    final isSelected = _selectedIssueType == issueType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIssueType = isSelected ? null : issueType;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 18 : 24,
          vertical: isSmallScreen ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(isIOS ? 15 : 12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF04CDFE)
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                issueType,
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                isIOS
                    ? CupertinoIcons.check_mark_circled_solid
                    : Icons.check_circle,
                color: const Color(0xFF04CDFE),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(bool isIOS, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESCRIPTION',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(isIOS ? 15 : 12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: isIOS
              ? CupertinoTextField(
                  controller: _descriptionController,
                  placeholder: 'PLEASE DESCRIBE THE ISSUE IN DETAIL ...',
                  placeholderStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 6,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(),
                  onChanged: (_) => setState(() {}),
                )
              : TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'PLEASE DESCRIBE THE ISSUE IN DETAIL ...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 48 : 52,
        child: isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                color: (_canSubmit && !_isSubmitting)
                    ? const Color(0xFF04CDFE)
                    : Colors.white.withValues(alpha: 0.3),
                disabledColor: Colors.white.withValues(alpha: 0.3),
                onPressed: (_canSubmit && !_isSubmitting)
                    ? _handleSubmit
                    : null,
                borderRadius: BorderRadius.circular(isIOS ? 12 : 10),
                child: _isSubmitting
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        'SUBMIT REPORT',
                        style: AppTheme.bebasNeue(
                          color: (_canSubmit && !_isSubmitting)
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
              )
            : ElevatedButton(
                onPressed: (_canSubmit && !_isSubmitting)
                    ? _handleSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit
                      ? const Color(0xFF04CDFE)
                      : Colors.white.withValues(alpha: 0.3),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'SUBMIT REPORT',
                        style: AppTheme.bebasNeue(
                          color: (_canSubmit && !_isSubmitting)
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final issueType = _selectedIssueType ?? 'OTHERS';
    final description = _descriptionController.text.trim();
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    try {
      // Call API to initiate chat
      final result = await ChatRepository.initiateChat(
        bookingId: widget.booking.id,
        description: description.isNotEmpty ? description : issueType,
        issue: description.isNotEmpty ? description : issueType,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Extract chat ID from response data
        final chatData = result['data'] as Map<String, dynamic>?;
        final chatId = chatData?['_id']?.toString() ?? '';

        // Navigate to chat screen with chat data and room ID, replacing current screen
        Navigator.of(context).pushReplacement(
          isIOS
              ? CupertinoPageRoute(
                  builder: (_) => IssueChatScreen(
                    booking: widget.booking,
                    issueType: issueType,
                    description: description,
                    chatData: chatData,
                    roomId: chatId,
                  ),
                )
              : MaterialPageRoute(
                  builder: (_) => IssueChatScreen(
                    booking: widget.booking,
                    issueType: issueType,
                    description: description,
                    chatData: chatData,
                    roomId: chatId,
                  ),
                ),
        );
      } else {
        // Show error message
        final errorMessage = result['message'] ?? 'Failed to initiate chat';
        if (isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Error'),
              content: Text(errorMessage),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = 'An error occurred: ${e.toString()}';
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
