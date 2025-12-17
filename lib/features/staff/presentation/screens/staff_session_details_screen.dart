import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../domain/models/booking_model.dart';
import '../providers/cleaner_booking_provider.dart';

class StaffSessionDetailsScreen extends StatefulWidget {
  final CleanerBooking booking;
  final String serviceName;
  final PackageSession session;
  final int sessionNumber;
  final int totalSessions;
  final int completedCount;
  final String? addonId;
  final String sessionType;

  const StaffSessionDetailsScreen({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.session,
    required this.sessionNumber,
    required this.totalSessions,
    required this.completedCount,
    this.addonId,
    required this.sessionType,
  });

  @override
  State<StaffSessionDetailsScreen> createState() =>
      _StaffSessionDetailsScreenState();
}

class _StaffSessionDetailsScreenState extends State<StaffSessionDetailsScreen> {
  Map<String, dynamic>? _sessionData;
  bool _isLoading = true;
  String? _error;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;
  String? _selectedImagePath; // Store selected image path before upload

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final bookingProvider = context.read<CleanerBookingProvider>();
    final result = await bookingProvider.getSession(
      bookingId: widget.booking.id,
      sessionId: widget.session.id,
      sessionType: widget.sessionType,
      addonId: widget.addonId,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _sessionData = result['data'];
        } else {
          _error = result['message'] ?? 'Failed to load session details';
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // Show action sheet/dialog to choose camera or gallery
    ImageSource? source;
    if (isIOS) {
      source = await showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text('Camera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text('Gallery'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ),
      );
    } else {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }

    if (source == null) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error picking image: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImagePath == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final bookingProvider = context.read<CleanerBookingProvider>();
      final result = await bookingProvider.uploadSessionImage(
        bookingId: widget.booking.id,
        sessionId: widget.session.id,
        sessionType: widget.sessionType,
        imagePath: _selectedImagePath!,
        addonId: widget.addonId,
      );

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });

        if (result['success'] == true) {
          // Update session data directly from upload API response body
          if (result['data'] != null) {
            setState(() {
              _sessionData = result['data'] as Map<String, dynamic>;
              _selectedImagePath = null; // Clear selected image after upload
            });
          } else {
            // Fallback: fetch session details if response doesn't have data
            await _fetchSessionDetails();
            if (mounted) {
              setState(() {
                _selectedImagePath = null;
              });
            }
          }

          // Show success message
          if (mounted) {
            _showMessage('Image uploaded successfully', isError: false);
          }
        } else {
          // Show error message
          if (mounted) {
            _showMessage(
              result['message'] ?? 'Failed to upload image',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        _showMessage('Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      // Use CupertinoAlertDialog for iOS
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(isError ? 'Error' : 'Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      // Use SnackBar for Android
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            duration: Duration(seconds: isError ? 3 : 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return Material(
      color: Colors.black,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: _buildContent(isIOS: true),
      ),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(isIOS: false),
    );
  }

  Widget _buildContent({required bool isIOS}) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
        final isTablet = screenWidth > 600;

        final horizontalPadding = isSmallScreen
            ? 16.0
            : isMediumScreen
            ? 20.0
            : isTablet
            ? 32.0
            : 20.0;

        // Calculate navigation bar dimensions
        final navBarMargin = isSmallScreen
            ? 12.0
            : isMediumScreen
            ? 14.0
            : isTablet
            ? 20.0
            : 16.0;
        final navBarHeight = isSmallScreen
            ? 60.0
            : isMediumScreen
            ? 65.0
            : isTablet
            ? 80.0
            : 70.0;
        final systemBottomPadding = MediaQuery.of(context).padding.bottom;
        final bottomPadding =
            navBarMargin + navBarHeight + systemBottomPadding + 16;

        if (_isLoading) {
          return SafeArea(
            bottom: false,
            child: Center(
              child: isIOS
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (_error != null) {
          return SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    isIOS
                        ? CupertinoButton(
                            onPressed: _fetchSessionDetails,
                            child: Text('Retry'),
                          )
                        : TextButton(
                            onPressed: _fetchSessionDetails,
                            child: Text('Retry'),
                          ),
                  ],
                ),
              ),
            ),
          );
        }

        // Use API data if available, otherwise fall back to session prop
        final sessionData = _sessionData;
        final completedBy = sessionData?['completedBy'] as List<dynamic>?;
        final images =
            sessionData?['images'] as List<dynamic>? ?? widget.session.images;
        final isCompleted =
            sessionData?['isCompleted'] as bool? ?? widget.session.isCompleted;
        final date = sessionData?['date'] != null
            ? DateTime.tryParse(sessionData!['date'].toString())
            : widget.session.date;
        final sessionId = sessionData?['_id'] as String? ?? widget.session.id;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, isIOS, isSmallScreen),
                SizedBox(height: 24),
                // Sessions Overview
                _buildSessionsOverview(
                  widget.completedCount,
                  widget.totalSessions,
                  isIOS,
                  isSmallScreen,
                ),
                SizedBox(height: 24),
                // Session Details Card
                _buildSessionDetailsCard(
                  isIOS,
                  isSmallScreen,
                  isTablet,
                  isCompleted: isCompleted,
                  date: date,
                  completedBy: completedBy,
                  sessionId: sessionId,
                ),
                SizedBox(height: 24),
                // Photos Section
                _buildPhotosSection(
                  isIOS,
                  isSmallScreen,
                  isTablet,
                  images: images,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isIOS, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back button in blue circular container on the left
          StandardBackButton(onPressed: () => Navigator.of(context).pop()),
          // Spacer to push heading to center
          const Spacer(),
          // Centered heading
          Column(
            children: [
              Text(
                'Session Details',
                style: AppTheme.bebasNeue(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'SESSION ${widget.sessionNumber} DETAILS',
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          // Spacer to balance the back button on the left
          const Spacer(),
          // Invisible placeholder to balance the back button
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSessionsOverview(
    int completedCount,
    int totalSessions,
    bool isIOS,
    bool isSmallScreen,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SESSIONS',
          style: AppTheme.bebasNeue(
            color: const Color(0xFF04CDFE),
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          '$completedCount/$totalSessions COMPLETED',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionDetailsCard(
    bool isIOS,
    bool isSmallScreen,
    bool isTablet, {
    required bool isCompleted,
    DateTime? date,
    List<dynamic>? completedBy,
    required String sessionId,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 18 : 24,
        vertical: isSmallScreen ? 20 : 26,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SESSION ${widget.sessionNumber}',
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: AppTheme.bebasNeue(
                      color: Colors.green,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
          SizedBox(height: 16),
          // Session ID
          _buildDetailRow('SESSION ID', sessionId, isIOS, isSmallScreen),
          SizedBox(height: 12),
          // Completion Status
          _buildDetailRow(
            'STATUS',
            isCompleted ? 'COMPLETED' : 'PENDING',
            isIOS,
            isSmallScreen,
          ),
          // Show completion details only if completed
          if (isCompleted) ...[
            SizedBox(height: 12),
            if (date != null)
              _buildDetailRow(
                'COMPLETED ON',
                _formatDateTime(date),
                isIOS,
                isSmallScreen,
              ),
            if (date != null) SizedBox(height: 12),
            _buildDetailRow(
              'COMPLETED BY',
              _formatCompletedBy(completedBy),
              isIOS,
              isSmallScreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isIOS,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isSmallScreen ? 100 : 120,
          child: Text(
            label,
            style: AppTheme.bebasNeue(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(
    bool isIOS,
    bool isSmallScreen,
    bool isTablet, {
    required List<dynamic> images,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PHOTOS',
              style: AppTheme.bebasNeue(
                color: const Color(0xFF04CDFE),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
            _isUploadingImage
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isIOS
                        ? const CupertinoActivityIndicator(
                            color: Color(0xFF04CDFE),
                          )
                        : SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF04CDFE),
                              strokeWidth: 2,
                            ),
                          ),
                  )
                : isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _pickImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.camera,
                          color: Color(0xFF04CDFE),
                          size: 24,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ADD IMAGE',
                          style: AppTheme.bebasNeue(
                            color: const Color(0xFF04CDFE),
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  )
                : IconButton(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF04CDFE),
                          size: 24,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ADD IMAGE',
                          style: AppTheme.bebasNeue(
                            color: const Color(0xFF04CDFE),
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    onPressed: _pickImage,
                  ),
          ],
        ),
        SizedBox(height: 16),
        _buildPhotoPlaceholder(isIOS, isSmallScreen, isTablet, images: images),
        // Show selected image preview and upload button
        if (_selectedImagePath != null) ...[
          SizedBox(height: 16),
          _buildSelectedImagePreview(isIOS, isSmallScreen),
          SizedBox(height: 16),
          _buildUploadButton(isIOS, isSmallScreen),
        ],
      ],
    );
  }

  Widget _buildSelectedImagePreview(bool isIOS, bool isSmallScreen) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadButton(bool isIOS, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF04CDFE),
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isUploadingImage ? null : _uploadImage,
              child: _isUploadingImage
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Text(
                      'UPLOAD IMAGE',
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: _isUploadingImage ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04CDFE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploadingImage
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'UPLOAD IMAGE',
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
    );
  }

  Widget _buildPhotoPlaceholder(
    bool isIOS,
    bool isSmallScreen,
    bool isTablet, {
    required List<dynamic> images,
  }) {
    // Convert images to List<String>
    final imageUrls = images.map((img) => img.toString()).toList();
    final hasPhotos = imageUrls.isNotEmpty;

    if (hasPhotos) {
      // Show photo grid if images exist
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    // Show placeholder if no photos
    return Container(
      height: isTablet ? 300 : 200,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isIOS ? CupertinoIcons.camera : Icons.camera_alt,
            color: Colors.grey[600],
            size: isTablet ? 80 : 60,
          ),
          SizedBox(height: 16),
          Text(
            'NO PHOTOS UPLOADED FOR THIS SESSION',
            style: AppTheme.bebasNeue(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatCompletedBy(List<dynamic>? completedBy) {
    if (completedBy == null || completedBy.isEmpty) return 'N/A';

    // Extract names from completedBy array
    final names = completedBy
        .map((item) {
          if (item is Map) {
            return item['name']?.toString() ?? '';
          }
          return item.toString();
        })
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) return 'N/A';
    return names.join(', ').toUpperCase();
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    final d = date.toLocal();
    final months = [
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
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[(d.month - 1).clamp(0, 11)]} ${d.day}, ${d.year} ${hour}:$minute $amPm';
  }
}
