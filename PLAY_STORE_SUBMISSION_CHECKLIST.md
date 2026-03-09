# Google Play Store Submission Checklist

This checklist will help you prepare your Krew Car Wash App for Google Play Store submission.

## Pre-Submission Requirements

### 1. Privacy Policy
- [ ] Create a publicly accessible privacy policy URL
  - Host your privacy policy on your website or use a privacy policy generator
  - Ensure the URL is accessible without authentication
  - Update the privacy policy with your actual business information
  - Replace placeholder text in PRIVACY_POLICY.md with your details

### 2. App Information
- [ ] App Name: "Krew Car Wash" (or your preferred name)
- [ ] Short Description (80 characters max)
- [ ] Full Description (4000 characters max)
- [ ] App Icon (512x512 PNG, 32-bit)
- [ ] Feature Graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, up to 8)
  - Phone screenshots (16:9 or 9:16)
  - Tablet screenshots (optional)
- [ ] Promo Video (optional, YouTube URL)

### 3. Content Rating
- [ ] Complete the content rating questionnaire
- [ ] Expected rating: "Everyone" or "Teen" (depending on content)

### 4. Target Audience
- [ ] Select target audience
- [ ] Age restrictions (if applicable)

### 5. Pricing and Distribution
- [ ] Set app as Free or Paid
- [ ] Select countries for distribution
- [ ] Set up pricing (if paid app)

## Data Safety Section (Required)

### 6. Data Collection
- [ ] Review PLAY_STORE_DATA_SAFETY.md
- [ ] Fill out Data Safety section in Play Console
- [ ] Answer all questions about data collection
- [ ] Specify which data is collected
- [ ] Specify which data is shared
- [ ] Provide privacy policy URL

### 7. Permissions
- [ ] Review all app permissions
- [ ] Justify each permission in the Data Safety section
- [ ] Ensure permissions are necessary for app functionality

## App Content

### 8. Store Listing
- [ ] App name
- [ ] Short description
- [ ] Full description
- [ ] App icon
- [ ] Feature graphic
- [ ] Screenshots
- [ ] Promo video (optional)

### 9. Store Listing Details
- [ ] Category: Lifestyle / Utilities / Automotive
- [ ] Tags/Keywords
- [ ] Contact email
- [ ] Website URL
- [ ] Privacy policy URL

## Technical Requirements

### 10. App Bundle
- [ ] Build Android App Bundle (AAB)
  ```bash
  flutter build appbundle --release
  ```
- [ ] Test the AAB file
- [ ] Ensure app bundle is signed with release keystore

### 11. Version Information
- [ ] Version Code: Increment for each release
- [ ] Version Name: e.g., "1.0.0"
- [ ] Update version in pubspec.yaml

### 12. Signing
- [ ] Release keystore configured
- [ ] Key.properties file set up
- [ ] Keystore file secured and backed up

### 13. Target SDK
- [ ] Target SDK: 34 (as per current configuration)
- [ ] Minimum SDK: 23 (as per current configuration)
- [ ] Compile SDK: 36 (as per current configuration)

## Testing

### 14. Pre-Launch Testing
- [ ] Test on multiple devices
- [ ] Test on different Android versions
- [ ] Test all core features:
  - [ ] User registration and login
  - [ ] Profile management
  - [ ] Booking creation
  - [ ] Payment processing
  - [ ] Location services
  - [ ] Push notifications
  - [ ] Chat/messaging (if applicable)

### 15. Internal Testing
- [ ] Create internal testing track
- [ ] Add testers
- [ ] Test app from Play Store
- [ ] Fix any critical issues

### 16. Closed Testing (Optional)
- [ ] Create closed testing track
- [ ] Add testers
- [ ] Gather feedback
- [ ] Make improvements

## Compliance

### 17. Privacy Compliance
- [ ] Privacy policy is complete and accurate
- [ ] Privacy policy URL is accessible
- [ ] Data Safety section is filled correctly
- [ ] All data collection is disclosed
- [ ] User rights are explained

### 18. Content Guidelines
- [ ] App content complies with Google Play policies
- [ ] No prohibited content
- [ ] Appropriate content rating
- [ ] No misleading information

### 19. Technical Requirements
- [ ] App doesn't crash on launch
- [ ] App doesn't violate security policies
- [ ] No malware or harmful code
- [ ] Proper error handling

## Firebase and Third-Party Services

### 20. Firebase Configuration
- [ ] google-services.json is properly configured
- [ ] Firebase project is set up correctly
- [ ] All Firebase services are enabled:
  - [ ] Authentication
  - [ ] Firestore
  - [ ] Cloud Messaging
  - [ ] Analytics
  - [ ] Cloud Functions

### 21. API Configuration
- [ ] Backend API is production-ready
- [ ] API URL is updated to production endpoint
- [ ] API is secure (HTTPS)
- [ ] Error handling is implemented

### 22. Payment Gateway
- [ ] Telr payment gateway is configured
- [ ] Test payments are working
- [ ] Production payment credentials are set
- [ ] Payment flow is tested

## Security

### 23. Security Measures
- [ ] Secure storage is implemented
- [ ] Tokens are stored securely
- [ ] API communication is encrypted (HTTPS)
- [ ] No sensitive data in logs
- [ ] ProGuard/R8 rules configured (if applicable)

### 24. Permissions
- [ ] Only necessary permissions are requested
- [ ] Runtime permissions are handled correctly
- [ ] Permission rationale is provided

## Final Steps

### 25. Pre-Launch Checklist
- [ ] All features are working
- [ ] No critical bugs
- [ ] Privacy policy is live
- [ ] Data Safety section is complete
- [ ] App is tested thoroughly
- [ ] Screenshots and graphics are ready
- [ ] Store listing is complete

### 26. Submission
- [ ] Create production release
- [ ] Upload AAB file
- [ ] Fill out release notes
- [ ] Review all information
- [ ] Submit for review

### 27. Post-Submission
- [ ] Monitor review status
- [ ] Respond to any reviewer questions
- [ ] Fix any issues if app is rejected
- [ ] Prepare for launch

## Important Notes

1. **Privacy Policy URL**: Must be publicly accessible. Consider hosting on:
   - Your website
   - GitHub Pages
   - Privacy policy generator services

2. **Data Safety Section**: This is mandatory. Google will reject your app if this is incomplete.

3. **Testing**: Thoroughly test your app before submission. Use internal testing track first.

4. **Version Management**: Increment version code for each release.

5. **Keystore Security**: Keep your release keystore file secure and backed up. You cannot update your app without it.

## Resources

- [Google Play Console](https://play.google.com/console)
- [Google Play Policy](https://play.google.com/about/developer-content-policy/)
- [Data Safety Section Guide](https://support.google.com/googleplay/android-developer/answer/10787469)
- [App Bundle Guide](https://developer.android.com/guide/app-bundle)

## Contact Information Template

Update these in your privacy policy and store listing:

- **Company Name**: [Your Company Name]
- **Contact Email**: [Your Email]
- **Website**: [Your Website]
- **Address**: [Your Business Address]
- **Phone**: [Your Phone Number]

---

**Last Updated**: [Date]

**Next Review**: [Date]

