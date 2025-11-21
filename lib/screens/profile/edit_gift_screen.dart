import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/profile.dart';
import '../../services/storage_service.dart';
import '../../themes/theme_helper.dart';
import '../../l10n/app_localizations.dart';

class EditGiftScreen extends StatefulWidget {
  final String profileId;
  final Gift? gift; // null = создание новой идеи, не null = редактирование

  const EditGiftScreen({
    super.key,
    required this.profileId,
    this.gift,
  });

  @override
  State<EditGiftScreen> createState() => _EditGiftScreenState();
}

class _EditGiftScreenState extends State<EditGiftScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSaving = false;

  Color _getPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;
  bool get _isEditing => widget.gift != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.gift != null) {
      _ideaController.text = widget.gift!.idea;
      _descriptionController.text = widget.gift!.description ?? '';
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGift() async {
    final idea = _ideaController.text.trim();
    
    if (idea.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Idea cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final description = _descriptionController.text.trim();
      final descriptionValue = description.isEmpty ? null : description;

      if (_isEditing && widget.gift != null) {
        // Обновляем существующую идею
        final updatedGift = widget.gift!.copyWith(
          idea: idea,
          description: descriptionValue,
        );
        await _storageService.updateGift(widget.profileId, updatedGift);
      } else {
        // Создаем новую идею
        final newGift = Gift(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          profileId: widget.profileId,
          idea: idea,
          description: descriptionValue,
          createdAt: DateTime.now(),
        );
        await _storageService.addGift(widget.profileId, newGift);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true); // Возвращаем true для обновления списка
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorSaving}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteGift() async {
    if (!_isEditing || widget.gift == null) return;
    if (!mounted) return;

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

    if (confirmed == true && mounted) {
      try {
        await _storageService.deleteGift(widget.profileId, widget.gift!.id);
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to update the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context).errorDeleting}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: context.iconColor, size: 24),
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
            mouseCursor: SystemMouseCursors.basic,
            tooltip: '',
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Карточка с полями
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field "Idea"
                TextField(
                  controller: _ideaController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).idea,
                    labelStyle: TextStyle(
                      color: context.secondaryTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Field "Description"
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).description,
                    labelStyle: TextStyle(
                      color: context.secondaryTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: context.textColor,
                  ),
                  maxLines: 15,
                  minLines: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Button "Save"
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _getPrimaryColor(context),
              boxShadow: [
                BoxShadow(
                  color: _getPrimaryColor(context).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveGift,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ).copyWith(
                splashFactory: NoSplash.splashFactory,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).saveChanges,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          // Button "Delete" (only when editing)
          if (_isEditing) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isSaving ? null : _deleteGift,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  AppLocalizations.of(context).deleteIdea,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

