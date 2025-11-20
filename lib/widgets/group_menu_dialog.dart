import 'package:flutter/material.dart';
import '../models/group.dart';
import '../localization/app_localizations.dart';
import '../theme/app_button_styles.dart';
import 'app_dialog.dart';

/// Modal window for the group menu (edit/delete)
class GroupMenuDialog {
  static Future<String?> show(BuildContext context, Group group, Color primaryColor) async {
    final localizations = AppLocalizations.of(context);
    
    return await AppDialog.showMenu(
      context: context,
      buttons: [
        DialogButton(
          text: localizations.delete,
          onPressed: () => Navigator.pop(context, 'delete'),
          style: AppButtonStyles.deleteButton(context),
        ),
        DialogButton(
          text: localizations.editAction,
          isPrimary: true,
          onPressed: () => Navigator.pop(context, 'edit'),
          style: AppButtonStyles.primaryButton(context, primaryColor),
        ),
      ],
    );
  }
}

