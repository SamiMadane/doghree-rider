import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/features/task/widgets/delivered_bottom_sheet.dart';
import 'package:wefrh_rider/features/task/widgets/reschedule_bottom_sheet.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;

  // موقع افتراضي (Al-Bureij Camp)
  final LatLng defaultLocation = const LatLng(31.5000, 34.4700);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'client'.tr,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.p16),
              margin: EdgeInsets.only(
                top: Dimensions.p16,
              ),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  // بطاقة المنتج (النصوص تجي من API لاحقاً)
                  CustomCard(
                    padding: EdgeInsets.all(Dimensions.p16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCard(
                            padding: const EdgeInsets.all(16),
                            isBorder: false,
                            borderRadius: Dimensions.r8,
                            fillColor: customColor.naturalBlue.withAlpha(20),
                            height: 55,
                            width: 55,
                            child: SvgPicture.asset(
                              ManagerAssets.newOrderIcon,
                              color: customColor.naturalBlue,
                            )),
                        const SizedBox(width: Dimensions.p16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Food package for kids", // من الـ API
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fs17),
                            ),
                            SizedBox(height: Dimensions.p4),
                            Text(
                              "World Lunch Organization", // من الـ API
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fs15,
                                  color: Theme.of(context).disabledColor),
                            ),
                            SizedBox(height: Dimensions.p4),
                            Text(PriceConverterHelper.convertPrice(590),
                                style: robotoSemiBold.copyWith(
                                    fontSize: Dimensions.fs22)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.p12,
                  ),
                  // العنوان
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("beneficiary_addresses".tr,
                            style:
                                robotoBold.copyWith(fontSize: Dimensions.fs18)),
                        SizedBox(
                          height: Dimensions.p12,
                        ),
                        CustomCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: Dimensions.r8,
                          fillColor: Theme.of(context).cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("original_titles".tr,
                                  style: robotoBold),
                              SizedBox(
                                height: Dimensions.p8,
                              ),
                              Text(
                                "Al-Bureij Camp, Western Sector, Tent No. 156", // من الـ API
                                style: robotoRegular.copyWith(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.p8),
                        CustomCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: Dimensions.r8,
                          fillColor: customColor.greenBg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("updated_address".tr,
                                  style: robotoBold.copyWith(
                                      color: customColor.green)),
                              Text(
                                  "Al-Bureij Camp, Western Sector, Tent No. 156, Medical Distribution Point", // من الـ API
                                  style: robotoRegular.copyWith(
                                      color: customColor.green)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.p12,
                        ),
                        // الخريطة
                        Container(
                          height: 250,
                          margin: const EdgeInsets.all(8),
                          child: currentLocation == null
                              ? Center(
                                  child: CircularProgressIndicator(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ))
                              : GoogleMap(
                                  onMapCreated: (controller) {
                                    mapController = controller;
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: currentLocation!,
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                        markerId: const MarkerId("current"),
                                        position: currentLocation!,
                                        infoWindow: InfoWindow(
                                            title: "your_location".tr)),
                                    Marker(
                                        markerId: const MarkerId("default"),
                                        position: defaultLocation,
                                        infoWindow: InfoWindow(
                                            title: "distribution_point".tr)),
                                  },
                                ),
                        ),
                        SizedBox(
                          height: Dimensions.p12,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'your_current_location'.tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs14),
                                ),
                                SizedBox(
                                  height: Dimensions.p4,
                                ),
                                Text(
                                  '34.4700 , 31.5000', // من API أو GPS
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs14,
                                      color: Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'distance'.tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs14),
                                ),
                                SizedBox(
                                  height: Dimensions.p4,
                                ),
                                Text(
                                  '242m', // من API أو حساب
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs14,
                                      color: Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.p12,
                  ),
                  // بيانات المستفيد
                  CustomCard(
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    padding: const EdgeInsets.all(16),
                    fillColor: Theme.of(context).scaffoldBackgroundColor,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Youssef Mahmoud Abdel Rahman", // من API
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs17)),
                                  Text("id_number".tr + ": 444555666",
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs15)),
                                  Text("phone".tr + ": 0595444555",
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs15)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: CustomCard(
                                borderRadius: Dimensions.r8,
                                padding: const EdgeInsets.all(16),
                                fillColor:
                                    Theme.of(context).cardColor,
                                height: 100,
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      ManagerAssets.identityIcon,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    SizedBox(
                                      height: Dimensions.p4,
                                    ),
                                    Text(
                                      'view_image_identity'.tr,
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs13),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.p20),
                        CustomCard(
                          padding: EdgeInsets.all(Dimensions.p16),
                          borderRadius: Dimensions.r8,
                          fillColor: ManagerColors.blueLightMode.withAlpha(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: CustomCard(
                                      padding: EdgeInsets.all(Dimensions.p16),
                                      height: 60,
                                      isBorder: false,
                                      fillColor: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      child: SvgPicture.asset(
                                        ManagerAssets.supportTeamIcon,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Dimensions.p12,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Text(
                                          'updated_info_support'.tr,
                                          style: robotoBold.copyWith(
                                              color: customColor.blue,
                                              fontSize: Dimensions.fs15),
                                        ),
                                        Text(
                                          "Ahmed Mohamed employee - text message", // من API
                                          style: robotoRegular.copyWith(
                                              color: ManagerColors.disabledDark,
                                              fontSize: Dimensions.fs13),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: Dimensions.p8,
                              ),
                              Text("last_update".tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs13)),
                              SizedBox(
                                height: Dimensions.p2,
                              ),
                              Text(" 03/08/2025 12:00:00 AM", // من API
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fs13)),
                              SizedBox(
                                height: Dimensions.p12,
                              ),
                              Text("important_notes".tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs15,
                                      color: customColor.blue)),
                              SizedBox(
                                height: Dimensions.p8,
                              ),
                              CustomCard(
                                padding: EdgeInsets.all(Dimensions.p8),
                                borderRadius: Dimensions.r8,
                                child: const Text(
                                  "Phone number updated - old number not working", // من API
                                  style: robotoRegular,
                                ),
                              ),
                              SizedBox(
                                height: Dimensions.p4,
                              ),
                              CustomCard(
                                padding: EdgeInsets.all(Dimensions.p8),
                                borderRadius: Dimensions.r8,
                                child: const Text(
                                    "Delivery can be made to any family member with ID", // من API
                                    style: robotoRegular),
                              ),
                              SizedBox(
                                height: Dimensions.p4,
                              ),
                              CustomCard(
                                  padding: EdgeInsets.all(Dimensions.p8),
                                  borderRadius: Dimensions.r8,
                                  child: const Text(
                                      "Make sure to call before you go", // من API
                                      style: robotoRegular)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.p20,
                        ),

                        // أزرار
                        Row(
                          children: [
                            Expanded(
                              child: CustomButtonWidget(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  ManagerAssets.directionIcon,
                                  color: ManagerColors.white,
                                  width: 22,
                                  height: 22,
                                ),
                                buttonText: 'direction'.tr,
                                radius: Dimensions.r8,
                                backgroundColor:
                                    ManagerColors.naturalBlueLightMode,
                                fontSize: Dimensions.fs13,
                              ),
                            ),
                            SizedBox(
                              width: Dimensions.p8,
                            ),
                            Expanded(
                              child: CustomButtonWidget(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  ManagerAssets.callIcon,
                                  color: ManagerColors.white,
                                  width: 22,
                                  height: 22,
                                ),
                                buttonText: 'contact'.tr,
                                radius: Dimensions.r8,
                                backgroundColor: ManagerColors.oliveGreen,
                                fontSize: Dimensions.fs14,
                              ),
                            ),
                            SizedBox(
                              width: Dimensions.p8,
                            ),
                            Expanded(
                              child: CustomButtonWidget(
                                onPressed: () {
                                  Get.toNamed(RouteHelper.getCaptureIdRoute());
                                },
                                icon: SvgPicture.asset(
                                  ManagerAssets.cameraIcon,
                                  color: ManagerColors.white,
                                  width: 22,
                                  height: 22,
                                ),
                                buttonText: 'record'.tr,
                                radius: Dimensions.r8,
                                backgroundColor: ManagerColors.purple,
                                fontSize: Dimensions.fs14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, -3), // ظل لأعلى
                  ),
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.r8),
                    topRight: Radius.circular(Dimensions.r8)),
              ),
              child: Column(
                children: [
                  CustomButtonWidget(
                    onPressed: () {
                      showCustomBottomSheet(
                          child: DeliveredBottomSheet(
                        beneficiaryName: 'Yusuf Mahmoud Abdulrahman',
                      ));
                    },
                    backgroundColor: ManagerColors.lightGreen,
                    buttonText: 'delivered'.tr,
                    fontSize: Dimensions.fs15,
                  ),
                  SizedBox(
                    height: Dimensions.p16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButtonWidget(
                          onPressed: () {
                            showCustomBottomSheet(
                                child: RescheduleBottomSheet(),
                                showCloseButton: false);
                          },
                          backgroundColor: ManagerColors.orangeLightMode,
                          buttonText: 'reschedule'.tr,
                          fontSize: Dimensions.fs15,
                        ),
                      ),
                      SizedBox(
                        width: Dimensions.p12,
                      ),
                      Expanded(
                        child: CustomButtonWidget(
                          onPressed: () {
                            Get.toNamed(RouteHelper.getSupportTeamRoute());
                          },
                          backgroundColor: ManagerColors.blueLightMode,
                          buttonText: 'support'.tr,
                          fontSize: Dimensions.fs15,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
