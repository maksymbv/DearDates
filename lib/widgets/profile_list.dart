import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/group.dart';
import 'profile_card.dart';

/// List of profiles with RefreshIndicator
class ProfileList extends StatelessWidget {
  final List<Profile> profiles;
  final List<Group> groups;
  final Color primaryColor;
  final String Function(String?) getGroupName;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onProfileUpdated;
  final Widget? header;
  final double? bottomPadding;

  const ProfileList({
    super.key,
    required this.profiles,
    required this.groups,
    required this.primaryColor,
    required this.getGroupName,
    required this.onRefresh,
    required this.onProfileUpdated,
    this.header,
    this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: primaryColor,
      displacement: 40,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomPadding ?? 100,
        ),
        itemCount: profiles.length + (header != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (header != null && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: header!,
            );
          }
          
          final profileIndex = header != null ? index - 1 : index;
          final profile = profiles[profileIndex];
          
          return ProfileCard(
            key: ValueKey(profile.id),
            profile: profile,
            primaryColor: primaryColor,
            onProfileUpdated: onProfileUpdated,
            groupName: getGroupName(profile.groupId),
          );
        },
      ),
    );
  }
}

