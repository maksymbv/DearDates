import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../localization/app_localizations.dart';

/// Custom DatePicker with support for iOS and Android
class CustomDatePicker {
  /// Show DatePicker (Cupertino for iOS, Material for Android)
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    DateTime? picked;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Use Cupertino date picker for iOS
      if (!context.mounted) return null;
      picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) => _CupertinoDatePickerWidget(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      );
    } else {
      // Use Material date picker for Android
      if (!context.mounted) return null;
      picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: const Locale('en', 'US'),
      );
    }

    return picked;
  }
}

/// Cupertino DatePicker widget for iOS
class _CupertinoDatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CupertinoDatePickerWidget({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CupertinoDatePickerWidget> createState() => _CupertinoDatePickerWidgetState();
}

class _CupertinoDatePickerWidgetState extends State<_CupertinoDatePickerWidget> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      padding: const EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? CupertinoColors.systemBackground.darkColor : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Control buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: TextStyle(
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(selectedDate),
                    child: Text(
                      AppLocalizations.of(context).done,
                      style: TextStyle(
                        color: isDark ? CupertinoColors.white : CupertinoColors.activeBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date picker
            Flexible(
              child: CupertinoDatePicker(
                initialDateTime: widget.initialDate,
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                mode: CupertinoDatePickerMode.date,
                use24hFormat: false,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    selectedDate = newDate;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

