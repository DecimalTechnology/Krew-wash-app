import 'package:flutter/material.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/constants/size_constants.dart';

class BookButtonWidget extends StatelessWidget {
  const BookButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        SizeConstants.getResponsivePadding(screenWidth) + 5,
        SizeConstants.getResponsivePadding(screenWidth) + 10,
        SizeConstants.getResponsivePadding(screenWidth) + 5,
        SizeConstants.getResponsivePadding(screenWidth) * 3,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.customerChooseSlot);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04CDFE),
          padding: EdgeInsets.symmetric(
            vertical: SizeConstants.getResponsivePadding(screenWidth) + 2,
            horizontal: SizeConstants.getResponsivePadding(screenWidth),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConstants.getResponsiveBorderRadius(screenWidth),
            ),
          ),
          elevation: SizeConstants.getResponsiveElevation(screenWidth),
          shadowColor: const Color(0xFF04CDFE).withValues(alpha: 0.3),
        ),
        child: Text(
          'BOOK YOUR SLOT',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConstants.getResponsiveFontSize(
              screenWidth,
              SizeConstants.hugeFontSize,
            ),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
