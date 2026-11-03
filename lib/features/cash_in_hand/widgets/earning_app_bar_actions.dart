import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/circle_icon_button.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/earning_filter_sheet.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

/// Download-invoice and filter buttons shown in the earnings app bar.
class EarningAppBarActions extends StatelessWidget {
  const EarningAppBarActions({super.key});

  void _download(CashInHandController c) {
    final int? id = Get.find<ProfileController>().profileModel?.id;
    if (id == null || c.downloadLoading == true) return;
    c.downloadEarningInvoice(dmId: id);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashInHandController>(builder: (c) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleIconButton(
            iconAsset: ManagerAssets.downloadIcon,
            isLoading: c.downloadLoading == true,
            onTap: () => _download(c),
          ),
          SizedBox(width: Dimensions.w8),
          CircleIconButton(
            iconAsset: ManagerAssets.filterIcon,
            showBadge: c.isFiltered,
            onTap: showEarningFilterSheet,
          ),
        ],
      );
    });
  }
}