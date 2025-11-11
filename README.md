# Dear Dates 🎁

An app for storing birthdays and gift ideas. Fully offline application.

## Features

- 📱 Fully offline - all data is stored locally
- 🎂 Track upcoming birthdays
- 🎁 Manage gift ideas
- ✅ Mark gifts as given
- 💾 SharedPreferences for local data storage
- 🎨 Modern Material Design 3 interface
- ✨ Auto-save on input

## Technologies

- **Flutter** - main framework
- **SharedPreferences** - for local storage (built-in AsyncStorage equivalent)
- **Dismissible** - built-in widget for swipe and delete
- **Material Design 3** - modern design out of the box
- **Intl** - for date handling

## Built-in Flutter Features Used

✅ **Navigation** - built-in Navigator (no third-party libraries)
✅ **Gestures** - built-in Dismissible for swipe
✅ **UI Components** - Material Design components
✅ **Animations** - built-in Flutter animations
✅ **Safe Area** - built-in SafeArea widget
✅ **Date Handling** - built-in DateTime + intl

## Installing Dependencies

```bash
flutter pub get
```

## Running

```bash
flutter run
```

## Functionality

- ✅ Screen with list of upcoming birthdays
- ✅ Add new profile (name, birthday, note)
- ✅ Editable gift ideas (auto-save)
- ✅ Mark gifts as given
- ✅ Swipe to delete gifts
- ✅ Local data storage (SharedPreferences)

## Implementation Details

1. **Auto-save**: When entering gift idea text, saving happens automatically 1 second after input stops
2. **Swipe to delete**: Uses built-in `Dismissible` widget
3. **Minimal dependencies**: Only necessary libraries are used (shared_preferences, intl)
4. **Built-in components**: Maximum use of Flutter's out-of-the-box capabilities
