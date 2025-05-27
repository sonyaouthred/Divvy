import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/screens/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays the tile for a member with their
/// profile image and name.
/// Parameters:
///   - member: the member to display
///   - spacing: the spacing of the parent screen.
///   - suffix: the suffix to be attached to the member's name,
///       if desired.
///   - button: if true, the member tile is tappable & displays a
///       trailing chevron.
class MemberTile extends StatelessWidget {
  // Member to be shown
  final Member member;
  // spacing between elements
  final double spacing;
  // text to follow the name of the member
  final String suffix;
  // True if button is tappable & chevron should be shown.
  final bool button;
  const MemberTile({
    super.key,
    required this.member,
    required this.spacing,
    this.suffix = '',
    this.button = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => (button) ? _openMemberPage(context, member) : (),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          SizedBox(height: spacing * 0.3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User profile image
              Row(
                children: [
                  Container(
                    decoration: DivvyTheme.profileCircle(
                      member.profilePicture.color,
                    ),
                    height: 25,
                    width: 25,
                  ),
                  SizedBox(width: spacing / 2),
                  Text('${member.name} $suffix', style: DivvyTheme.bodyBlack),
                ],
              ),
              // Display chevron icon
              if (button)
                Flexible(
                  flex: 1,
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    color: DivvyTheme.lightGrey,
                    size: 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing / 2),
          if (button) Divider(color: DivvyTheme.altBeige),
        ],
      ),
    );
  }

  ///////////////////////////// util /////////////////////////////

  /// Opens the page for a specific member.
  void _openMemberPage(BuildContext context, Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UserInfoScreen(memberID: member.id)),
    );
  }
}
