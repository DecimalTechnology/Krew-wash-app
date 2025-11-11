# Bebas Neue Font Setup Instructions

## ⚠️ Current Status: Font Configuration Temporarily Disabled

The Bebas Neue font configuration has been temporarily commented out in `pubspec.yaml` to prevent build errors. The app is currently using Roboto as the default font family.

## 📁 Font Files Required

To complete the Bebas Neue font implementation, you need to add the following font files to the `fonts/` directory:

### Required Font Files:
1. `fonts/BebasNeue-Regular.ttf`
2. `fonts/BebasNeue-Bold.ttf`

## 📥 How to Get Bebas Neue Font

### Option 1: Download from Google Fonts
1. Go to [Google Fonts - Bebas Neue](https://fonts.google.com/specimen/Bebas+Neue)
2. Click "Download family"
3. Extract the ZIP file
4. Copy the following files to your `fonts/` directory:
   - `BebasNeue-Regular.ttf`
   - `BebasNeue-Bold.ttf`

### Option 2: Use Web Fonts
1. Download from [Font Squirrel](https://www.fontsquirrel.com/fonts/bebas-neue)
2. Extract and copy the TTF files to `fonts/` directory

## 📂 Directory Structure
```
carwash_app/
├── fonts/
│   ├── BebasNeue-Regular.ttf
│   └── BebasNeue-Bold.ttf
├── lib/
│   └── core/
│       └── theme/
│           ├── app_theme.dart
│           └── text_styles.dart
└── pubspec.yaml
```

## ✅ After Adding Font Files

1. **Uncomment Font Configuration in pubspec.yaml:**
   ```yaml
   fonts:
     - family: BebasNeue
       fonts:
         - asset: fonts/BebasNeue-Regular.ttf
         - asset: fonts/BebasNeue-Bold.ttf
           weight: 700
   ```

2. **Update Theme Configuration:**
   - Change `fontFamily = 'Roboto'` to `fontFamily = 'BebasNeue'` in `lib/core/theme/app_theme.dart`

3. **Run Flutter Commands:**
   ```bash
   flutter clean
   flutter pub get
   ```

4. **Test the App:**
   - The app will now use Bebas Neue font throughout
   - All text will have the distinctive Bebas Neue styling
   - Responsive text sizing is already implemented

## 🎨 Font Usage in Code

The app now uses Bebas Neue font through the `AppTextStyles` class:

```dart
// Example usage:
Text(
  'Your Text',
  style: AppTextStyles.responsiveTitle(context),
)

// Custom styling:
Text(
  'Custom Text',
  style: AppTextStyles.bebasNeue(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)
```

## 🔧 Available Text Styles

- `AppTextStyles.largeTitle` - Large titles (32px)
- `AppTextStyles.title` - Regular titles (24px)
- `AppTextStyles.subtitle` - Subtitles (18px)
- `AppTextStyles.body` - Body text (16px)
- `AppTextStyles.bodySmall` - Small body text (14px)
- `AppTextStyles.caption` - Caption text (12px)
- `AppTextStyles.button` - Button text (16px)
- `AppTextStyles.buttonSmall` - Small button text (14px)

### Responsive Styles:
- `AppTextStyles.responsiveTitle(context)` - Responsive title
- `AppTextStyles.responsiveSubtitle(context)` - Responsive subtitle
- `AppTextStyles.responsiveBody(context)` - Responsive body
- `AppTextStyles.responsiveCaption(context)` - Responsive caption
- `AppTextStyles.responsiveButton(context)` - Responsive button

## 🎯 Benefits

1. **Consistent Typography**: All text uses Bebas Neue font
2. **Responsive Design**: Text scales based on screen size
3. **Easy Maintenance**: Centralized font management
4. **Professional Look**: Modern, clean typography throughout the app
