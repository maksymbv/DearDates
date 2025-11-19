import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/profile.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_helper.dart';
import '../localization/app_localizations.dart';

/// Виджет для редактирования подарка с собственным управлением состоянием
class EditableGiftItem extends StatefulWidget {
  final Gift gift;
  final bool isFuture; // Будущий подарок (можно редактировать) или уже подаренный
  final Color primaryColor;
  final Future<void> Function(String giftId, String newText) onSave;
  final Future<void> Function(String giftId) onDelete;
  final Future<void> Function(String giftId) onToggleStatus;

  const EditableGiftItem({
    super.key,
    required this.gift,
    required this.isFuture,
    required this.primaryColor,
    required this.onSave,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  State<EditableGiftItem> createState() => _EditableGiftItemState();
}

class _EditableGiftItemState extends State<EditableGiftItem> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.gift.idea);
    _focusNode = FocusNode();
    
    // Сохраняем при потере фокуса
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_isSaving) {
        _saveGift();
      }
    });
  }

  @override
  void didUpdateWidget(EditableGiftItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем текст, если подарок изменился извне
    if (oldWidget.gift.idea != widget.gift.idea && !_focusNode.hasFocus) {
      _controller.text = widget.gift.idea;
    }
  }

  @override
  void dispose() {
    // Сохраняем перед удалением, если есть изменения
    if (_controller.text.trim() != widget.gift.idea.trim() && !_isSaving) {
      widget.onSave(widget.gift.id, _controller.text.trim());
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveGift() async {
    if (_isSaving) return;
    
    final newText = _controller.text.trim();
    // Если текст не изменился, не сохраняем
    if (newText == widget.gift.idea.trim()) return;
    
    // Если текст пустой, не сохраняем (будет удален при следующем обновлении)
    if (newText.isEmpty) return;
    
    setState(() => _isSaving = true);
    try {
      await widget.onSave(widget.gift.id, newText);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    if (!context.mounted) return;
    final localizations = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.deleteGiftConfirm,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.areYouSure,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          localizations.cancel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          localizations.delete,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    
    if (confirmed == true) {
      await widget.onDelete(widget.gift.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.gift.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: Text(
            AppLocalizations.of(context).delete,
            style: AppTextStyles.button(context).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        await _handleDelete();
        return false; // Не удаляем автоматически, так как удаление обрабатывается в _handleDelete
      },
      onDismissed: (_) => widget.onDelete(widget.gift.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: widget.isFuture 
              ? (context.isDarkMode
                  ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6))
              : (context.isDarkMode
                  ? Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.4)
                  : Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: widget.isFuture
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: 'Идея подарка...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _saveGift(),
                      onEditingComplete: _saveGift,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: context.textColor,
                        fontSize: 15,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        widget.gift.idea,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: context.iconColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
            if (widget.isFuture)
              GestureDetector(
                onTap: () => widget.onToggleStatus(widget.gift.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    LucideIcons.check,
                    color: widget.primaryColor,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

