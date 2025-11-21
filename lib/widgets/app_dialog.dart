import 'package:flutter/material.dart';
import '../themes/app_button_styles.dart';
import '../themes/app_text_styles.dart';
import '../themes/theme_helper.dart';

/// Widget for the dialog with a text field
class _TextFieldDialogWidget extends StatefulWidget {
  final String title;
  final String labelText;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final Color primaryColor;
  final int maxLength;
  final String? Function(String?)? validator;
  final bool autofocus;

  const _TextFieldDialogWidget({
    required this.title,
    required this.labelText,
    this.initialValue,
    required this.confirmText,
    required this.cancelText,
    required this.primaryColor,
    required this.maxLength,
    this.validator,
    required this.autofocus,
  });

  @override
  State<_TextFieldDialogWidget> createState() => _TextFieldDialogWidgetState();
}

class _TextFieldDialogWidgetState extends State<_TextFieldDialogWidget> {
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        Navigator.pop(context, text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.title,
                  style: AppTextStyles.heading2(context).copyWith(
                    fontSize: widget.title.length > 20 ? 18 : 20,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextField(
                    controller: _controller,
                    autofocus: widget.autofocus,
                    maxLength: widget.maxLength,
                    decoration: InputDecoration(
                      labelText: widget.labelText,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          widget.cancelText,
                          style: AppTextStyles.button(context).copyWith(
                            color: context.textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: AppButtonStyles.primaryButton(context, widget.primaryColor),
                        child: Text(
                          widget.confirmText,
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

/// Button for the dialog
class DialogButton {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isPrimary;

  const DialogButton({
    required this.text,
    this.onPressed,
    this.style,
    this.isPrimary = false,
  });
}

/// Universal dialog for the application
class AppDialog {
  // Flag to prevent multiple openings
  static bool _isDialogOpen = false;

  /// Show dialog with a title, content and buttons
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    required List<DialogButton> buttons,
    bool isScrollControlled = false,
    EdgeInsets? padding,
  }) async {
    // Protection from multiple openings
    if (_isDialogOpen) return null;
    _isDialogOpen = true;

    try {
      return await showModalBottomSheet<T>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: isScrollControlled,
        isDismissible: true,
        enableDrag: true,
        builder: (context) => Container(
        decoration: AppButtonStyles.modalContainer(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isScrollControlled
                  ? MediaQuery.of(context).viewInsets.bottom
                  : 0,
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: AppTextStyles.heading2(context).copyWith(
                        fontSize: title.length > 20 ? 18 : 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  content,
                  if (buttons.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildButtons(context, buttons),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    } finally {
      // Reset the flag after the dialog is closed
      Future.delayed(const Duration(milliseconds: 300), () {
        _isDialogOpen = false;
      });
    }
  }

  /// Build buttons
  static Widget _buildButtons(BuildContext context, List<DialogButton> buttons) {
    if (buttons.length == 1) {
      // One button for the full width
      final button = buttons.first;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: button.onPressed,
          style: button.style ??
              AppButtonStyles.primaryButton(
                context,
                Theme.of(context).colorScheme.primary,
              ),
          child: Text(
            button.text,
            style: AppTextStyles.button(context),
          ),
        ),
      );
    } else if (buttons.length == 2) {
      // Two buttons next to each other
      return Row(
        children: [
          Expanded(
            child: _buildButton(context, buttons[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildButton(context, buttons[1]),
          ),
        ],
      );
    } else {
      // Many buttons - vertically
      return Column(
        children: buttons.map((btn) => _buildButton(context, btn)).toList(),
      );
    }
  }

  /// Build one button
  static Widget _buildButton(BuildContext context, DialogButton button) {
    if (button.isPrimary) {
      return ElevatedButton(
        onPressed: button.onPressed,
        style: button.style ??
            AppButtonStyles.primaryButton(
              context,
              Theme.of(context).colorScheme.primary,
            ),
        child: Text(
          button.text,
          style: AppTextStyles.button(context),
        ),
      );
    } else {
      return TextButton(
        onPressed: button.onPressed,
        style: button.style ??
            TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ).copyWith(
              splashFactory: NoSplash.splashFactory,
            ),
        child: Text(
          button.text,
          style: AppTextStyles.button(context).copyWith(
            color: context.textColor,
          ),
        ),
      );
    }
  }

  /// Dialog with a text field (for creating/editing)
  static Future<String?> showTextField({
    required BuildContext context,
    required String title,
    required String labelText,
    String? initialValue,
    required String confirmText,
    String cancelText = 'Cancel',
    Color? primaryColor,
    int maxLength = 30,
    String? Function(String?)? validator,
    bool autofocus = true,
  }) async {
    // Protection from multiple openings
    if (_isDialogOpen) return null;
    _isDialogOpen = true;

    try {
      return await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) => _TextFieldDialogWidget(
        title: title,
        labelText: labelText,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        primaryColor: primaryColor ?? Theme.of(context).colorScheme.primary,
        maxLength: maxLength,
        validator: validator,
        autofocus: autofocus,
      ),
    );
    } finally {
      // Reset the flag after the dialog is closed
      Future.delayed(const Duration(milliseconds: 300), () {
        _isDialogOpen = false;
      });
    }
  }

  /// Dialog with a menu (two buttons next to each other)
  static Future<String?> showMenu({
    required BuildContext context,
    required List<DialogButton> buttons,
    EdgeInsets? padding,
  }) async {
    // Protection from multiple openings
    if (_isDialogOpen) return null;
    _isDialogOpen = true;

    try {
      return await show<String>(
        context: context,
        content: const SizedBox.shrink(),
        buttons: buttons,
        padding: padding ?? const EdgeInsets.all(20),
      );
    } finally {
      // Reset the flag after the dialog is closed
      Future.delayed(const Duration(milliseconds: 300), () {
        _isDialogOpen = false;
      });
    }
  }
}

