import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_drop_down_button.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class MyEarningFilterScreen extends StatefulWidget {
  const MyEarningFilterScreen({super.key});

  @override
  State<MyEarningFilterScreen> createState() => _MyEarningFilterScreenState();
}

class _MyEarningFilterScreenState extends State<MyEarningFilterScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'filter_by'.tr),

      body: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return Column(children: [

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
              child: Column(children: [

                CustomDropdownButton(
                  hintText: 'select_earning_types'.tr,
                  dropdownMenuItems: cashInHandController.earningTypes.map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.tr, style: textRegular().copyWith(fontSize: Dimensions.fs14)),
                  )).toList(),
                  isBorder: true,
                  backgroundColor: Theme.of(context).cardColor,
                  onChanged: (value) {
                    cashInHandController.setEarningType(value);
                  },
                  selectedValue: cashInHandController.selectedEarningType,
                ),
                SizedBox(height: Dimensions.h25),

                CustomDropdownButton(
                  hintText: 'select_date_range'.tr,
                  dropdownMenuItems: cashInHandController.dateTypes.map((range) => DropdownMenuItem<String>(
                    value: range,
                    child: Text(range.tr, style: textRegular().copyWith(fontSize: Dimensions.fs14)),
                  )).toList(),
                  isBorder: true,
                  backgroundColor: Theme.of(context).cardColor,
                  onChanged: (value) {
                    cashInHandController.setDateType(value);
                  },
                  selectedValue: cashInHandController.selectedDateType,
                ),

                Visibility(
                  visible: cashInHandController.selectedDateType == 'custom_date_range',
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal:Dimensions.w10 ,vertical: Dimensions.h10,),
                    margin: EdgeInsetsDirectional.only(top: Dimensions.h25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.r10),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      cashInHandController.from != null && cashInHandController.to != null ? Text(
                        '${cashInHandController.from} - ${cashInHandController.to}', style: textRegular(),
                      ) : Text('custom_date_range'.tr, style: textRegular().copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),

                      InkWell(
                        onTap: () {
                          cashInHandController.showDatePicker(context);
                        },
                        child: Icon(Icons.calendar_month_rounded, color: Theme.of(context).hintColor),
                      ),

                    ]),
                  ),
                ),

              ]),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.r4),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
            ),
            child: Row(children: [

              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'reset'.tr,
                  backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.25),
                  fontColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    cashInHandController.resetEarningFilter();
                    cashInHandController.getEarningReport(
                      offset: '1',
                      startDate: cashInHandController.from, endDate: cashInHandController.to,
                      type: cashInHandController.selectedEarningType,
                    ).then((value) {
                      Get.back(result: true);
                    });
                  },
                ),
              ),
              SizedBox(width: Dimensions.w10),

              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'apply_filter'.tr,
                  isLoading: cashInHandController.isLoading,
                  onPressed: () {
                    cashInHandController.showBottomLoader();
                    cashInHandController.getEarningReport(
                      offset: 1.toString(),
                      startDate: cashInHandController.from, endDate: cashInHandController.to,
                      type: cashInHandController.selectedEarningType,
                      fromFilter: true,
                    ).then((value) {
                      Get.back(result: true);
                    });
                  },
                ),
              ),

            ]),
          ),

        ]);
      }),
    );
  }
}
