import 'package:flutter/material.dart';
import '../models/group.dart';
import '../l10n/app_localizations.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_button_styles.dart';

/// Result of editing group dialog
class EditGroupResult {
  final String? newName;
  final bool shouldDelete;

  const EditGroupResult({this.newName, this.shouldDelete = false});
}

/// Edit group dialog
class EditGroupDialog {
  static Future<EditGroupResult?> show(BuildContext context, Group group, Color primaryColor) async {
    return await showModalBottomSheet<EditGroupResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _EditGroupDialogWidget(
        group: group,
        primaryColor: primaryColor,
      ),
    );
  }
}

class _EditGroupDialogWidget extends StatefulWidget {
  final Group group;
  final Color primaryColor;

  const _EditGroupDialogWidget({
    required this.group,
    required this.primaryColor,
  });

  @override
  State<_EditGroupDialogWidget> createState() => _EditGroupDialogWidgetState();
}

class _EditGroupDialogWidgetState extends State<_EditGroupDialogWidget> {
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.group.name);
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, EditGroupResult(newName: text));
    }
  }

  void _handleDelete() {
    Navigator.pop(context, EditGroupResult(shouldDelete: true));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      decoration: AppButtonStyles.modalContainer(context),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.editGroup,
                  style: AppTextStyles.heading2(context).copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: localizations.groupName,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    onSubmitted: (_) => _handleSave(),
                  ),
                ),
                const SizedBox(height: 24),
                // Кнопки Удалить и Сохранить
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _handleDelete,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          localizations.delete,
                          style: AppTextStyles.button(context).copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: AppButtonStyles.primaryButton(context, widget.primaryColor),
                        child: Text(
                          localizations.save,
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
