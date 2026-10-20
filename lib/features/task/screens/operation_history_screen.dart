import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/title_widget.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class DetailedOperationHistoryScreen extends StatefulWidget {
  const DetailedOperationHistoryScreen({super.key});

  @override
  State<DetailedOperationHistoryScreen> createState() =>
      _DetailedOperationHistoryScreenState();
}

class _DetailedOperationHistoryScreenState
    extends State<DetailedOperationHistoryScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'operations_history'.tr),
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
        child: Column(
          children: [
            _buildButtonsRow(),
            SizedBox(height: Dimensions.h16),
            Expanded(child: _buildSelectedContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildButton(title: 'delivered'.tr, index: 0),
          _buildButton(title: 'postponed'.tr, index: 1),
          _buildButton(title: 'waiting'.tr, index: 2),
          _buildButton(title: 'problem'.tr, index: 3),
        ],
      ),
    );
  }

  Widget _buildButton({required String title, required int index}) {
    bool isSelected = selectedIndex == index;

    return CustomButtonWidget(
      onPressed: () => setState(() => selectedIndex = index),
      height: Dimensions.h40,
      buttonText: title,
      margin: EdgeInsetsDirectional.only(end: Dimensions.w10),
      isBorder: !isSelected,
      transparent: !isSelected,
      color: Theme.of(context).textTheme.bodyMedium!.color,
      textColor: isSelected
          ? Theme.of(context).cardColor
          : Theme.of(context).hintColor,
      isBold: isSelected,
      autoWidth: true,
    );
  }

  Widget _buildSelectedContent() {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;
    
    final configs = [
      {'status': 'Delivered', 'color': ManagerColors.darkGreen},
      {'status': 'Postponed', 'color': ManagerColors.orangeLightMode},
      {'status': 'Waiting', 'color': customColor.naturalBlue},
      {'status': 'Problem', 'color': Theme.of(context).primaryColor},
    ];

    final config = configs[selectedIndex];
    return _buildOperationsTab(
      config['status'] as String,
      config['color'] as Color,
    );
  }

  Widget _buildOperationsTab(String status, Color statusColor) {
    return ListView(
      children: [
        _buildOperationsSection(
          title: status,
          color: statusColor,
          itemCount: 3,
        ),
      ],
    );
  }

  Widget _buildOperationsSection({
    required String title,
    required Color color,
    required int itemCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleWidget(
          titleStyle: textSemiBold().copyWith(
            fontSize: Dimensions.fs16,
            color: color,
          ),
          title: title,
          orderCount: itemCount,
          backGroundColorOfCount: color,
          showOrderCount: true,
        ),
        SizedBox(height: Dimensions.h16),
        ...List.generate(itemCount, (_) => _buildOperationItem()),
      ],
    );
  }

  Widget _buildOperationItem() {
    final textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return CustomCard(
      margin: EdgeInsets.only(bottom: Dimensions.h16),
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemHeader(textColor),
          SizedBox(height: Dimensions.h16),
          _buildDashedDivider(customColor.strock2),
          SizedBox(height: Dimensions.h16),
          _buildInfoRow(
            icon: ManagerAssets.orderIcon,
            label: 'type'.tr,
            value: 'Comprehensive food basket',
            textColor: textColor,
          ),
          SizedBox(height: Dimensions.h16),
          _buildInfoRow(
            icon: ManagerAssets.clockIcon,
            label: 'time'.tr,
            value: 'Today, 10:30 AM',
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(Color textColor) {
    return Row(
      children: [
        ClipOval(
          child: CustomImageWidget(height: 35, width: 35),
        ),
        SizedBox(width: Dimensions.w8),
        Expanded(
          child: Text(
            'Sami Al-Madani',
            style: textSemiBold().copyWith(
              color: textColor,
              fontSize: Dimensions.fs14,
            ),
          ),
        ),
        _buildPriceChip(),
      ],
    );
  }

  Widget _buildPriceChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w12,
        vertical: Dimensions.h4,
      ),
      decoration: BoxDecoration(
        color: ManagerColors.darkGreen,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        PriceConverterHelper.convertPrice(590),
        style: textSemiBold().copyWith(
          color: Theme.of(context).cardColor,
          fontSize: Dimensions.fs14,
        ),
      ),
    );
  }

  Widget _buildDashedDivider(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(width: 5, height: 2, color: color),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          height: Dimensions.h16,
          width: Dimensions.w16,
          color: Theme.of(context).hintColor,
        ),
        SizedBox(width: Dimensions.w4),
        Expanded(
          child: Text(
            label,
            style: textRegular().copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fs12,
            ),
          ),
        ),
        Text(
          value,
          style: textSemiBold().copyWith(
            color: textColor,
            fontSize: Dimensions.fs13,
          ),
        ),
      ],
    );
  }
}