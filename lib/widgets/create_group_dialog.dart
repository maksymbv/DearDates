import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import 'app_dialog.dart';

/// Create group dialog
class CreateGroupDialog {
  static Future<String?> show(BuildContext context, Color primaryColor) async {
    final localizations = AppLocalizations.of(context);
    
    return await AppDialog.showTextField(
      context: context,
      title: localizations.createGroup,
      labelText: localizations.groupName,
      confirmText: localizations.create,
      cancelText: localizations.cancel,
      primaryColor: primaryColor,
      maxLength: 30,
    );
  }
}

