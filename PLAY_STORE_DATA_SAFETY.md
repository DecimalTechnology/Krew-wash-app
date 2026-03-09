# Google Play Store - Data Safety Information

This document provides information for filling out the Google Play Console Data Safety section for the Krew Car Wash App.

## Data Collection and Sharing

### Personal Information Collected

#### Name
- **Collected**: Yes
- **Required**: Yes
- **Purpose**: Account identification, service personalization
- **Shared**: Yes (with service providers/cleaners for service delivery)

#### Email Address
- **Collected**: Yes
- **Required**: Yes
- **Purpose**: Account creation, authentication, communication
- **Shared**: No (except with backend service providers)

#### Phone Number
- **Collected**: Yes
- **Required**: Yes
- **Purpose**: Account verification (SMS OTP), service communication
- **Shared**: Yes (with service providers/cleaners for service coordination)

#### User IDs
- **Collected**: Yes
- **Required**: Yes
- **Purpose**: Account identification, authentication
- **Shared**: No (except with backend service providers)

#### Address
- **Collected**: Yes (Building ID, Apartment Number)
- **Required**: Yes
- **Purpose**: Service delivery location
- **Shared**: Yes (with service providers/cleaners for service delivery)

#### Photos
- **Collected**: Yes (Profile photos, optional)
- **Required**: No
- **Purpose**: User profile customization
- **Shared**: No

### Financial Information

#### Purchase History
- **Collected**: Yes (Booking records, payment amounts)
- **Required**: Yes
- **Purpose**: Service booking management, payment processing
- **Shared**: Yes (with payment gateway provider - Telr)

### App Activity

#### App Interactions
- **Collected**: Yes
- **Required**: No
- **Purpose**: Analytics, app improvement
- **Shared**: Yes (with Firebase Analytics)

#### In-app Search History
- **Collected**: No
- **Required**: No

#### Other User-Generated Content
- **Collected**: Yes (Chat messages, if applicable)
- **Required**: No
- **Purpose**: Customer support, service coordination
- **Shared**: Yes (with service providers/cleaners)

### Device or Other IDs

#### Device ID
- **Collected**: Yes (Firebase Installation ID, Push Notification Token)
- **Required**: Yes
- **Purpose**: Push notifications, app functionality
- **Shared**: Yes (with Firebase Cloud Messaging)

## Location Data

### Approximate Location
- **Collected**: Yes
- **Required**: No (Optional permission)
- **Purpose**: Display location on maps, service delivery assistance
- **Shared**: Yes (with Google Maps, service providers when needed)

### Precise Location
- **Collected**: Yes
- **Required**: No (Optional permission)
- **Purpose**: Display precise location on maps, help service providers locate vehicle
- **Shared**: Yes (with Google Maps, service providers when needed)

## Data Security Practices

### Data Encryption
- **In Transit**: Yes (HTTPS/TLS encryption)
- **At Rest**: Yes (Encrypted secure storage, Firebase encryption)

### Data Deletion
- **User-Requested Deletion**: Yes (Users can request account deletion)
- **Automatic Deletion**: Yes (Data retention policies apply)

### Security Practices
- Secure token-based authentication
- Encrypted local storage (Flutter Secure Storage)
- Secure backend API communication
- Regular security updates

## Data Sharing

### Third-Party Services

#### Firebase (Google)
- **Data Shared**: User authentication data, user profile, booking data, analytics data, push notification tokens
- **Purpose**: Authentication, database storage, analytics, push notifications
- **Privacy Policy**: https://firebase.google.com/support/privacy

#### Google Services
- **Data Shared**: Location data (Google Maps), authentication data (Google Sign-In)
- **Purpose**: Location services, social authentication
- **Privacy Policy**: https://policies.google.com/privacy

#### Telr Payment Gateway
- **Data Shared**: Payment transaction data, booking information
- **Purpose**: Payment processing
- **Privacy Policy**: Refer to Telr's official privacy policy

#### Backend API Server
- **Data Shared**: All user data, booking data, vehicle information
- **Purpose**: Service management, booking processing
- **Privacy Policy**: [Your Backend Privacy Policy URL]

#### Service Providers/Cleaners
- **Data Shared**: Booking details, vehicle information, contact information, location
- **Purpose**: Service delivery
- **Privacy Policy**: [Your Service Provider Agreement]

## Data Collection Practices

### Data Collection
- **Collection Required**: Yes (for core app functionality)
- **Collection Optional**: Some features (location, profile photos, chat)

### Data Usage
- **Service Delivery**: Primary purpose
- **Analytics**: App improvement and bug fixes
- **Communication**: Service updates and notifications
- **Legal Compliance**: Fraud prevention, legal requirements

### Data Retention
- **User Data**: Retained while account is active
- **Booking Data**: Retained for service history and legal compliance
- **Analytics Data**: Aggregated and anonymized
- **Deletion**: Available upon user request

## User Rights

### Access
- Users can view their data through the app's profile section

### Deletion
- Users can request account deletion
- Data will be deleted per data retention policies

### Correction
- Users can update their information through the app

### Data Portability
- Users can request a copy of their data

## Children's Privacy

- **Age Restriction**: App is not intended for users under 13 years of age
- **Data Collection from Children**: We do not knowingly collect data from children

## Compliance

### GDPR (European Users)
- Complies with General Data Protection Regulation requirements
- Provides user rights as specified in GDPR

### CCPA (California Users)
- Complies with California Consumer Privacy Act requirements
- Provides user rights as specified in CCPA

## Privacy Policy URL

**Privacy Policy**: [Your Privacy Policy URL - e.g., https://yourwebsite.com/privacy-policy]

**Last Updated**: [Date]

---

## Instructions for Google Play Console

1. **Go to**: Google Play Console → Your App → Policy → App content → Data safety

2. **Fill in the following sections**:
   - Data collection and security
   - Data sharing
   - Data types collected
   - Data types shared
   - Security practices
   - Privacy policy URL

3. **Answer the questions** based on the information provided above

4. **Upload Privacy Policy**: Ensure your privacy policy is hosted at a publicly accessible URL

5. **Review and Submit**: Review all information before submitting for review

---

**Note**: This document is a guide. Please review and customize based on your specific implementation and consult with legal professionals to ensure full compliance with Google Play policies and applicable privacy laws.

