import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class DetailedOperationHistoryScreen extends StatelessWidget {
  const DetailedOperationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: CustomAppBarWidget(
            title: 'detailed_operations_history'.tr,
            bottom: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              dividerColor: Colors.transparent, // منع الخط الرمادي الجانبي
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              tabs: [
                Tab(text: 'delivered'.tr),
                Tab(text: 'postponed'.tr),
                Tab(text: 'waiting'.tr),
                Tab(text: 'problem'.tr),
              ],
            )),
        body: TabBarView(
          children: [
            _operationsTab('Delivered', ManagerColors.darkGreen, context),
            _operationsTab('Postponed', ManagerColors.orangeLightMode, context),
            _operationsTab('Waiting', customColor.naturalBlue, context),
            _operationsTab('Problem', Theme.of(context).primaryColor, context),
          ],
        ),
      ),
    );
  }

  Widget _operationsTab(String status, Color color, BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Dimensions.p16),
      children: [
        _operationsSection(
          title: '$status (3)',
          color: color,
          items: List.generate(3, (_) => _operationItem(status, context)),
        ),
      ],
    );
  }

  Widget _operationsSection({
    required String title,
    required Color color,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                robotoBold.copyWith(fontSize: Dimensions.fs16, color: color)),
        SizedBox(height: Dimensions.p8),
        Column(children: items),
        SizedBox(height: Dimensions.p16),
      ],
    );
  }

  Widget _operationItem(String status, BuildContext context) {
    Color text = (Theme.of(context).textTheme.bodyMedium?.color)!;

    return CustomCard(
      margin: EdgeInsets.only(bottom: Dimensions.p8),
      padding: EdgeInsets.all(Dimensions.p12),
      borderRadius: Dimensions.r8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sami Emad Sami Al-Madani',
                    style: robotoBold.copyWith(
                        color: text, fontSize: Dimensions.fs15)),
                SizedBox(height: Dimensions.p4),
                Text('Comprehensive food basket',
                    style: robotoRegular.copyWith(
                        color: text, fontSize: Dimensions.fs14)),
                SizedBox(height: Dimensions.p2),
                Text('Today, 10:30 AM',
                    style: robotoRegular.copyWith(
                        color: text, fontSize: Dimensions.fs14)),
              ],
            ),
          ),
          Text(PriceConverterHelper.convertPrice(590),
              style: robotoSemiBold.copyWith(
                  color: text, fontSize: Dimensions.fs15)),
        ],
      ),
    );
  }
}
