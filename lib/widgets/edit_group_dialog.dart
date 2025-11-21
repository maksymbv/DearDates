import 'package:flutter/material.dart';
import '../models/group.dart';
import '../l10n/app_localizations.dart';
import 'app_dialog.dart';

/// Edit group dialog
class EditGroupDialog {
  static Future<String?> show(BuildContext context, Group group, Color primaryColor) async {
    final localizations = AppLocalizations.of(context);
    
    return await AppDialog.showTextField(
      context: context,
      title: localizations.editGroup,
      labelText: localizations.groupName,
      initialValue: group.name,
      confirmText: localizations.save,
      cancelText: localizations.cancel,
      primaryColor: primaryColor,
      maxLength: 30,
    );
  }
}

