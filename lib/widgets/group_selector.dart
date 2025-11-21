import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../themes/app_text_styles.dart';
import '../themes/theme_helper.dart';
import '../l10n/app_localizations.dart';

/// Bottom sheet for selecting a group
class GroupSelector {
  static Future<String?> show(
    BuildContext context, {
    required String? selectedGroupId,
    required Color primaryColor,
  }) async {
    if (!context.mounted) return null;
    return await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GroupSelectorContent(
        selectedGroupId: selectedGroupId,
        primaryColor: primaryColor,
      ),
    );
  }
}

class _GroupSelectorContent extends StatefulWidget {
  final String? selectedGroupId;
  final Color primaryColor;

  const _GroupSelectorContent({
    required this.selectedGroupId,
    required this.primaryColor,
  });

  @override
  State<_GroupSelectorContent> createState() => _GroupSelectorContentState();
}

class _GroupSelectorContentState extends State<_GroupSelectorContent> {
  final GroupService _groupService = GroupService();
  List<Group> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await _groupService.getAllGroups();
    setState(() {
      _groups = groups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).selectGroup,
                    style: AppTextStyles.heading2(context).copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      size: 24,
                      color: context.iconColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else
              // List of groups
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // "All"
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context).noGroup,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 16,
                          fontWeight: widget.selectedGroupId == null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: widget.selectedGroupId == null
                              ? widget.primaryColor
                              : context.textColor,
                        ),
                      ),
                      trailing: widget.selectedGroupId == null
                          ? Icon(
                              LucideIcons.check,
                              color: widget.primaryColor,
                              size: 24,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, null),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    
                    // List of groups
                    ..._groups.map((group) {
                      final isSelected = widget.selectedGroupId == group.id;
                      return ListTile(
                        title: Text(
                          group.name,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? widget.primaryColor
                                : context.textColor,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                LucideIcons.check,
                                color: widget.primaryColor,
                                size: 24,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, group.id),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

