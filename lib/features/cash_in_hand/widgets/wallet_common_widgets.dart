import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/dashed_line_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_method_logos.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// Base surface for the cards on the wallet screens.
/// Same look as the home cards: white surface, hairline outline, radius 20.
/// Built on Material so InkWell ripples inside it stay visible.
class WalletCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const WalletCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: theme.cardColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.r20),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}

/// Dashed "road" divider, same as the earnings card on home.
class WalletDashedDivider extends StatelessWidget {
  final double? vertical;

  const WalletDashedDivider({super.key, this.vertical});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w20,
        vertical: vertical ?? Dimensions.h12,
      ),
      child: DashedLine(
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            .withValues(alpha: 0.35),
      ),
    );
  }
}

/// Section title with an optional "see all" action.
class WalletSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const WalletSectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textBold().copyWith(
              fontSize: Dimensions.fs18,
              color: cs.onSurface,
            ),
          ),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w4,
                vertical: Dimensions.h4,
              ),
              child: Text(
                'wallet_see_all'.tr,
                style: textMedium().copyWith(
                  fontSize: Dimensions.fs14,
                  color: cs.tertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Payout method avatar: the method logo when one is registered in
/// wallet_method_logos.dart, otherwise a monogram (same as the details sheet).
class WalletMethodAvatar extends StatelessWidget {
  final String name;
  final double size;

  const WalletMethodAvatar({super.key, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final String? logo = walletMethodLogo(name);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(logo == null ? 0 : Dimensions.w8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: logo == null ? cs.primaryContainer : theme.cardColor,
        border: logo == null ? null : Border.all(color: cs.outline),
      ),
      child: logo != null
          ? Image.asset(logo, fit: BoxFit.contain)
          : Text(
              name.isEmpty ? '•' : String.fromCharCode(name.runes.first),
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
                color: cs.onPrimaryContainer,
              ),
            ),
    );
  }
}

/// Borderless history list: rows on the page itself, hairlines between them.
class WalletActivityList extends StatelessWidget {
  final List<Widget> rows;

  const WalletActivityList({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final Color line = Theme.of(context).colorScheme.outline;

    // Transparent Material so the row ripples stay visible on the page colour.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: WalletActivityRow.contentIndent,
                color: line,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// One history row: method avatar, title + date, amount + status.
class WalletActivityRow extends StatelessWidget {
  final String avatarName;
  final Color color;
  final String title;
  final String subtitle;
  final String amount;
  final String statusLabel;
  final VoidCallback? onTap;

  const WalletActivityRow({
    super.key,
    required this.avatarName,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.statusLabel,
    this.onTap,
  });

  static double get avatarSize => Dimensions.w20 * 2;

  /// Where the text starts, so dividers can align with it.
  static double get contentIndent => avatarSize + Dimensions.w12;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.h14),
        child: Row(
          children: [
            WalletMethodAvatar(name: avatarName, size: avatarSize),
            SizedBox(width: Dimensions.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium().copyWith(
                      fontSize: Dimensions.fs14,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: Dimensions.h2),
                  Text(
                    subtitle,
                    textDirection: TextDirection.ltr,
                    style: textRegular().copyWith(
                      fontSize: Dimensions.fs12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.w12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  textDirection: TextDirection.ltr,
                  style: textBold().copyWith(
                    fontSize: Dimensions.fs16,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: Dimensions.h2),
                WalletStatusLabel(label: statusLabel, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Coloured dot + plain text: quiet, no filled badge.
class WalletStatusLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double? fontSize;
  final double? dotSize;

  const WalletStatusLabel({
    super.key,
    required this.label,
    required this.color,
    this.fontSize,
    this.dotSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize ?? Dimensions.w6,
          height: dotSize ?? Dimensions.w6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: Dimensions.w6),
        Text(
          label,
          style: textMedium().copyWith(
            fontSize: fontSize ?? Dimensions.fs12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}