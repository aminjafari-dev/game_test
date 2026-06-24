import 'package:gap/gap.dart';

/// Standardized spacing values used across the horror survival UI.
///
/// Prefer [GGap.h8] over raw [SizedBox] heights for consistent layout.
/// Example: `Column(children: [GText('Health'), GGap.h8, healthBar])`
class GGap {
  GGap._();

  static const Gap h4 = Gap(4);
  static const Gap h8 = Gap(8);
  static const Gap h12 = Gap(12);
  static const Gap h16 = Gap(16);
  static const Gap h24 = Gap(24);
  static const Gap h32 = Gap(32);
  static const Gap w8 = Gap(8);
  static const Gap w16 = Gap(16);
}
