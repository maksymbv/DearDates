import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/profile.dart';
import '../../models/group.dart';
import '../../services/storage_service.dart';
import '../../services/group_service.dart';
import '../../utils/date_utils.dart';
import '../../widgets/group_badge.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/avatar.dart';
import 'add_profile_screen.dart';
import 'edit_gift_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;

  const ProfileScreen({super.key, required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final GroupService _groupService = GroupService();
  Profile? _profile;
  List<Group> _groups = [];
  bool _isLoading = true;
  
  Color _getPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final profiles = await _storageService.loadProfiles();
    
    if (!mounted) return;
    
    final profile = profiles.firstWhere(
      (p) => p.id == widget.profileId,
      orElse: () => Profile(
        id: '',
        name: '',
        birthdate: DateTime.now(),
        createdAt: DateTime.now(),
        avatarColor: 0xFFD68A9E,
      ),
    );
    
    // If the profile is not found (was deleted), close the screen
    if (profile.id.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    final groups = await _groupService.getAllGroups();

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _groups = groups;
      _isLoading = false;
    });
  }


  Future<void> _openGiftEditor(Gift? gift) async {
    if (_profile == null) return;
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGiftScreen(
          profileId: _profile!.id,
          gift: gift,
        ),
      ),
    );

    // If true, then there were changes - reload the profile
    if (result == true && mounted) {
      await _loadProfile();
    }
  }


  Future<void> _toggleGiftStatus(String giftId) async {
    if (_profile == null) return;

    final gift = _profile!.gifts.firstWhere((g) => g.id == giftId);
    final isNowGiven = !gift.isGiven;
    final currentYear = DateTime.now().year;
    
    // Логика года:
    // - Если становится подаренным И года еще нет → устанавливаем текущий год
    // - В остальных случаях сохраняем существующий год (не сбрасываем)
    final updatedGift = gift.copyWith(
      isGiven: isNowGiven,
      givenYear: isNowGiven && gift.givenYear == null 
          ? currentYear 
          : gift.givenYear,
    );
    await _storageService.updateGift(_profile!.id, updatedGift);
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: _getPrimaryColor(context).withOpacity(0.7),
          ),
        ),
      );
    }
    
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).profileNotFound),
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
        body: Center(child: Text(AppLocalizations.of(context).profileNotFound)),
      );
    }

    final profile = _profile!;
    final age = getAge(profile.birthdate);
    final futureGifts = profile.gifts.where((g) => !g.isGiven).toList();
    final pastGifts = profile.gifts.where((g) => g.isGiven).toList();
    
    // Group given gifts by years
    final Map<int, List<Gift>> giftsByYear = {};
    for (var gift in pastGifts) {
      final year = gift.givenYear ?? DateTime.now().year; // If the year is not specified, use the current year
      if (!giftsByYear.containsKey(year)) {
        giftsByYear[year] = [];
      }
      giftsByYear[year]!.add(gift);
    }
    
    // Sort years in descending order (new years at the top)
    final sortedYears = giftsByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor, size: 24),
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
        ),
        actions: [
          // Edit button
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(LucideIcons.pencil, size: 24, color: context.iconColor),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProfileScreen(profile: profile),
                  ),
                );
                if (result == true) {
                  await _loadProfile();
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
        ],
      ),
      bottomNavigationBar: null,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large circular photo
                    AvatarWidget(
                      photoPath: profile.photoPath,
                      avatarColor: profile.avatarColor,
                      name: profile.name,
                      size: 100,
                      fontSize: 48,
                    ),
                    const SizedBox(height: 20),
                    // Name in bold
                    Text(
                      profile.name,
                      style: AppTextStyles.heading1(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Age that will be reached on the birthday
                    Text(
                      getBirthdayAgeText(profile.birthdate, context),
                      style: AppTextStyles.secondary(context).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Group badge
                    if (profile.groupId != null) ...[
                      const SizedBox(height: 14),
                      Builder(
                        builder: (context) {
                          try {
                            final groupId = profile.groupId;
                            if (groupId != null) {
                              final group = _groups.firstWhere((g) => g.id == groupId);
                              return GroupBadge(
                                groupName: group.name,
                                primaryColor: _getPrimaryColor(context),
                              );
                            }
                            return const SizedBox.shrink();
                          } catch (e) {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                    // Notes at the bottom
                    if (profile.notes != null && profile.notes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      child: Text(
                        profile.notes!,
                        style: AppTextStyles.body(context).copyWith(
                          color: context.textColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gift card
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppLocalizations.of(context).giftIdeas,
                      style: AppTextStyles.heading2(context),
                    ),

                    // Gift ideas
                    if (futureGifts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...futureGifts.map((gift) => _buildGiftCard(gift, true)),
                    ],

                    // Already given (grouped by years)
                    if (pastGifts.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        AppLocalizations.of(context).alreadyGiven,
                        style: AppTextStyles.heading2(context),
                      ),
                      const SizedBox(height: 16),
                      // Display gifts by years
                      ...sortedYears.expand((year) {
                        final yearGifts = giftsByYear[year]!;
                        return [
                          // Year title
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 12,
                              top: year == sortedYears.first ? 0 : 20,
                            ),
                            child: Text(
                              year.toString(),
                              style: AppTextStyles.secondary(context).copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          // Gifts of this year
                          ...yearGifts.map((gift) => _buildGiftCard(gift, false)),
                        ];
                      }),
                    ],

                    if (profile.gifts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.gift,
                                size: 48,
                                color: context.secondaryTextColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).noGiftsYet,
                                style: AppTextStyles.body(context).copyWith(
                                  color: context.secondaryTextColor.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context).addFirst,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Material(
        color: _getPrimaryColor(context),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _openGiftEditor(null),
          customBorder: const CircleBorder(),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: Icon(LucideIcons.gift, color: Colors.white, size: 24),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }


  Widget _buildGiftCard(Gift gift, bool isFuture) {
    final primaryColor = _getPrimaryColor(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGiftEditor(gift),
          borderRadius: BorderRadius.circular(16),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.idea,
                        style: TextStyle(
                          color: gift.isGiven ? context.secondaryTextColor : context.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      if (gift.description != null && gift.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          gift.description!,
                          style: TextStyle(
                            color: context.secondaryTextColor,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Checkbox circle
                GestureDetector(
                  onTap: () => _toggleGiftStatus(gift.id),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gift.isGiven ? primaryColor : Colors.transparent,
                      border: Border.all(
                        color: gift.isGiven ? primaryColor : context.secondaryTextColor,
                        width: 2,
                      ),
                    ),
                    child: gift.isGiven
                        ? Icon(
                            LucideIcons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

