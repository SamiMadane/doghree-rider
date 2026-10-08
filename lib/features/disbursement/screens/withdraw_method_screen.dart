import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/disbursement/controllers/disbursement_controller.dart';
import 'package:wefrh_rider/features/disbursement/domain/models/disbursement_method_model.dart';
import 'package:wefrh_rider/features/disbursement/helper/disbursement_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/features/disbursement/widgets/confirm_dialog_widget.dart';

class WithdrawMethodScreen extends StatefulWidget {
  final bool isFromDashboard;
  const WithdrawMethodScreen({super.key, required this.isFromDashboard});

  @override
  State<WithdrawMethodScreen> createState() => _WithdrawMethodScreenState();
}

class _WithdrawMethodScreenState extends State<WithdrawMethodScreen> {

  DisbursementHelper disbursementHelper = DisbursementHelper();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  initCall() async {

    Get.find<DisbursementController>().getWithdrawMethodList();
    disbursementHelper.enableDisbursementWarningMessage(false, canShowDialog: !widget.isFromDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'disbursement_methods'.tr),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddWithdrawMethodRoute()),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: GetBuilder<DisbursementController>(builder: (disbursementController) {
        return disbursementController.disbursementMethodBody != null ? disbursementController.disbursementMethodBody!.methods!.isNotEmpty ? ListView.builder(
          itemCount: disbursementController.disbursementMethodBody!.methods!.length,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          itemBuilder: (context, index) {
            Methods method = disbursementController.disbursementMethodBody!.methods![index];
            return Container(
              width: context.width,
              margin: EdgeInsets.only(bottom: Dimensions.h16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 3))],
              ),
              child: Column(children: [

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.w16, vertical: Dimensions.h4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    Flexible(
                      child: Text(
                        '${'payment_method'.tr} : ${method.methodName}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: textBold().copyWith(fontSize: Dimensions.fs16),
                      ),
                    ),

                    method.isDefault == true ?  Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.r10),
                      ),
                      padding: EdgeInsets.all(Dimensions.fs12),
                      child: Text('default_method'.tr, style: textMedium().copyWith(color: Theme.of(context).primaryColor),),
                    ) : InkWell(
                      onTap: () {
                        disbursementController.makeDefaultMethod({'id': '${method.id}', 'is_default': '1'}, index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.r10),
                        ),
                        padding: EdgeInsets.all(Dimensions.fs12),
                        child: !(disbursementController.isLoading && (index == disbursementController.index))
                          ? Text('make_default'.tr, style: textMedium().copyWith(color: Theme.of(context).cardColor))
                          : SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor)),
                      ),
                    ),

                  ]),
                ),

                const Divider(height: 1, thickness: 0.5),

                Padding(
                  padding: EdgeInsets.only(left: Dimensions.w16, right: Dimensions.w16, top: Dimensions.h16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

                    Expanded(
                      child: ListView.builder(
                        itemCount: method.methodFields!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: Dimensions.h16),
                            child: Row(children: [
                              Expanded(
                                child: Text(method.methodFields![index].userInput!.replaceAll('_', ' '),
                                    style: textRegular().copyWith(color: Theme.of(context).disabledColor)),
                              ),
                               Text(' :  ', style: textRegular()),

                              Expanded(
                                child: Text(
                                  '${method.methodFields![index].userData}',
                                  style: textBold().copyWith(fontSize: Dimensions.fs14),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            ]),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: Dimensions.w16),

                    InkWell(
                      onTap: () {
                        Get.dialog(ConfirmDialogWidget(id: method.id!));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.h16, top: Dimensions.h16),
                        child: Icon(CupertinoIcons.delete, color: Theme.of(context).colorScheme.error, size: 20),
                      ),
                    )
                  ]),
                ),

              ]),

            );
          },
        ) : Center(child: Text('no_method_found'.tr, style: textMedium())) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
