import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/group.dart';
import 'profile_card.dart';

/// Список профилей с RefreshIndicator
class ProfileList extends StatelessWidget {
  final List<Profile> profiles;
  final List<Group> groups;
  final Color primaryColor;
  final String Function(String?) getGroupName;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onProfileUpdated;

  const ProfileList({
    super.key,
    required this.profiles,
    required this.groups,
    required this.primaryColor,
    required this.getGroupName,
    required this.onRefresh,
    required this.onProfileUpdated,
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
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
        ),
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          
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

