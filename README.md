# Dear Dates 🎁

An app for storing birthdays and gift ideas. Fully offline application with multi-language support.

## Main Features

- 📱 **Fully Offline** - all data is stored locally on the device
- 🎂 **Birthday Tracking** - automatic sorting by upcoming dates
- 🎁 **Gift Ideas Management** - create, edit, and track gift ideas
- ✅ **Mark Gifts as Given** - gift history grouped by years
- 📸 **Profile Photos** - ability to add photos to profiles
- 👥 **Groups** - organize profiles by groups (family, friends, colleagues, etc.)
- 🔔 **Notifications** - reminders for upcoming birthdays
- 🌍 **Multi-language** - support for English, Russian, and Ukrainian
- 🎨 **Themes** - light and dark themes with accent color selection (pink/blue)
- 🔍 **Search** - quick search by name, notes, and gift ideas

## Technologies

- **Flutter** - main framework
- **Hive** - fast NoSQL database for local storage
- **flutter_local_notifications** - local notifications
- **image_picker** - profile photo selection and storage
- **intl** - date formatting with localization support
- **lucide_icons_flutter** - modern icons
- **Material Design 3** - modern interface design

## Functionality

### Profile Management
- ✅ Add profiles (name, birthdate, notes, photo, group)
- ✅ Edit profiles
- ✅ Delete profiles
- ✅ Automatic age calculation
- ✅ Display days until next birthday

### Gift Management
- ✅ Create gift ideas with descriptions
- ✅ Edit gift ideas on a separate page
- ✅ Mark gifts as given
- ✅ Gift history grouped by years
- ✅ Delete gift ideas

### Groups
- ✅ Create groups to organize profiles
- ✅ Edit and delete groups
- ✅ Filter profiles by groups
- ✅ Automatic profile relocation when deleting a group

### Notifications
- ✅ Configure reminder days (1, 3, 7, 14, 30 days before birthday)
- ✅ Notification on the birthday itself
- ✅ Localized notification texts

### Settings
- ✅ Theme selection (light/dark)
- ✅ Accent color selection (pink/blue)
- ✅ Notification settings
- ✅ Automatic device language detection

## Installing Dependencies

```bash
flutter pub get
```

## Generating Hive Adapters

After installing dependencies, you need to generate adapters for models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running

```bash
flutter run
```

## Supported Languages

- 🇬🇧 **English** - automatically detected based on device language
- 🇷🇺 **Russian** - automatically detected based on device language
- 🇺🇦 **Ukrainian** - automatically detected based on device language

If the device language is not supported, English is used as default.

## Project Structure

```
lib/
├── adapters/          # Hive adapters for models
├── localization/      # Application localization
├── models/           # Data models (Profile, Gift, Group)
├── screens/          # Application screens
├── services/         # Services (storage, notifications, themes)
├── theme/            # Themes and styles
├── utils/            # Utilities (date formatting)
└── widgets/          # Reusable widgets
```

## Implementation Details

1. **Hive for Data Storage** - fast and efficient NoSQL database
2. **Automatic Localization** - language detection based on device settings
3. **Localized Dates** - date formatting in the corresponding language
4. **Smart Declension** - proper word declension for Russian and Ukrainian
5. **Universal Dialogs** - single template for all dialog windows
6. **Optimized Performance** - update only changed data

## Author

Made by Max Baranov with ❤️
