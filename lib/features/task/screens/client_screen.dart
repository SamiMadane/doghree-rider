import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:geolocator/geolocator.dart';
import 'package:doghree_rider/doghree_map/doghree_map.dart';
import 'package:doghree_rider/doghree_map/map_safety.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/task/widgets/delivered_bottom_sheet.dart';
import 'package:doghree_rider/features/task/widgets/reschedule_bottom_sheet.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final MapController _mapController = MapController();
  LatLng? currentLocation;

  // موقع افتراضي (Al-Bureij Camp)
  final LatLng defaultLocation = const LatLng(31.5000, 34.4700);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// يكبّر الخريطة لتشمل نقطة التوزيع وموقعي (النقاط الخاطئة تُحذف أولاً)
  void _fitMap() {
    final pts = usablePoints([
      defaultLocation,
      if (currentLocation != null) currentLocation!,
    ]);
    if (pts.length >= 2) {
      _mapController.fitCamera(CameraFit.coordinates(
        coordinates: pts,
        padding: const EdgeInsets.all(48),
        maxZoom: 17,
      ));
    } else if (pts.length == 1) {
      _mapController.move(pts.first, 16);
    }
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

    if (!mounted) return;
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Widget _buildMap() {
    final config = Get.find<SplashController>().doghreeMapConfig;
    if (config == null) {
      // إعدادات الخريطة لم تصل من /api/v1/config بعد
      return Image.asset(ManagerAssets.mapPlaceholderImage, fit: BoxFit.cover);
    }

    // موقعي يُرسم فقط إذا كان داخل غزة (وإلا لا نشوّه الخريطة)
    final myPoint = parsePoint(
        currentLocation?.latitude, currentLocation?.longitude);

    return DoghreeMap(
      config: config,
      controller: _mapController,
      initialCenter: defaultLocation,
      initialZoom: 14,
      onMapReady: _fitMap,
      children: [
        MarkerLayer(markers: [
          if (myPoint != null)
            Marker(
              point: myPoint,
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
          Marker(
            point: defaultLocation,
            width: 40,
            height: 40,
            alignment: Alignment.topCenter, // رأس الدبوس على النقطة
            child: const Icon(Icons.location_on, size: 40, color: Colors.red),
          ),
        ]),
      ],
    );
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
              padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
              margin: EdgeInsets.only(
                top: Dimensions.h16,
              ),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  // بطاقة المنتج (النصوص تجي من API لاحقاً)
                  CustomCard(
                    padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCard(
                            padding: EdgeInsets.all(16),
                            isBorder: false,
                            borderRadius: Dimensions.r8,
                            fillColor: customColor.naturalBlue.withAlpha(20),
                            height: 55,
                            width: 55,
                            child: SvgPicture.asset(
                              ManagerAssets.newOrderIcon,
                              color: customColor.naturalBlue,
                            )),
                        SizedBox(width: Dimensions.w16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Food package for kids", // من الـ API
                              style: textBold()
                                  .copyWith(fontSize: Dimensions.fs17),
                            ),
                            SizedBox(height: Dimensions.h4),
                            Text(
                              "World Lunch Organization", // من الـ API
                              style: textBold().copyWith(
                                  fontSize: Dimensions.fs15,
                                  color: Theme.of(context).disabledColor),
                            ),
                            SizedBox(height: Dimensions.h4),
                            Text(PriceConverterHelper.convertPrice(590),
                                style: textSemiBold()
                                    .copyWith(fontSize: Dimensions.fs22)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.h12,
                  ),
                  // العنوان
                  CustomCard(
                    padding: EdgeInsets.all(16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("beneficiary_addresses".tr,
                            style:
                                textBold().copyWith(fontSize: Dimensions.fs18)),
                        SizedBox(
                          height: Dimensions.h12,
                        ),
                        CustomCard(
                          padding: EdgeInsets.all(16),
                          borderRadius: Dimensions.r8,
                          fillColor: Theme.of(context).cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("original_titles".tr, style: textBold()),
                              SizedBox(
                                height: Dimensions.h8,
                              ),
                              Text(
                                "Al-Bureij Camp, Western Sector, Tent No. 156", // من الـ API
                                style: textRegular().copyWith(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.h8),
                        CustomCard(
                          padding: EdgeInsets.all(16),
                          borderRadius: Dimensions.r8,
                          fillColor: customColor.greenBg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("updated_address".tr,
                                  style: textBold()
                                      .copyWith(color: customColor.green)),
                              Text(
                                  "Al-Bureij Camp, Western Sector, Tent No. 156, Medical Distribution Point", // من الـ API
                                  style: textRegular()
                                      .copyWith(color: customColor.green)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.h12,
                        ),
                        // الخريطة
                        Container(
                          height: 250,
                          margin: EdgeInsets.all(8),
                          child: currentLocation == null
                              ? Center(
                                  child: CircularProgressIndicator(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ))
                              : _buildMap(),
                        ),
                        SizedBox(
                          height: Dimensions.h12,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'your_current_location'.tr,
                                  style: textBold()
                                      .copyWith(fontSize: Dimensions.fs14),
                                ),
                                SizedBox(
                                  height: Dimensions.h4,
                                ),
                                Text(
                                  '34.4700 , 31.5000', // من API أو GPS
                                  style: textBold().copyWith(
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
                                  style: textBold()
                                      .copyWith(fontSize: Dimensions.fs14),
                                ),
                                SizedBox(
                                  height: Dimensions.h4,
                                ),
                                Text(
                                  '242m', // من API أو حساب
                                  style: textBold().copyWith(
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
                    height: Dimensions.h12,
                  ),
                  // بيانات المستفيد
                  CustomCard(
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    padding: EdgeInsets.all(16),
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
                                      style: textBold()
                                          .copyWith(fontSize: Dimensions.fs17)),
                                  Text("id_number".tr + ": 444555666",
                                      style: textBold()
                                          .copyWith(fontSize: Dimensions.fs15)),
                                  Text("phone".tr + ": 0595444555",
                                      style: textBold()
                                          .copyWith(fontSize: Dimensions.fs15)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: CustomCard(
                                borderRadius: Dimensions.r8,
                                padding: EdgeInsets.all(16),
                                fillColor: Theme.of(context).cardColor,
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
                                      height: Dimensions.h4,
                                    ),
                                    Text(
                                      'view_image_identity'.tr,
                                      style: textBold()
                                          .copyWith(fontSize: Dimensions.fs13),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.h20),
                        CustomCard(
                          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
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
                                      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
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
                                    width: Dimensions.w12,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Text(
                                          'updated_info_support'.tr,
                                          style: textBold().copyWith(
                                              color: customColor.blue,
                                              fontSize: Dimensions.fs15),
                                        ),
                                        Text(
                                          "Ahmed Mohamed employee - text message", // من API
                                          style: textRegular().copyWith(
                                              color: ManagerColors.disabledDark,
                                              fontSize: Dimensions.fs13),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: Dimensions.h8,
                              ),
                              Text("last_update".tr,
                                  style: textBold()
                                      .copyWith(fontSize: Dimensions.fs13)),
                              SizedBox(
                                height: Dimensions.h2,
                              ),
                              Text(" 03/08/2025 12:00:00 AM", // من API
                                  style: textRegular()
                                      .copyWith(fontSize: Dimensions.fs13)),
                              SizedBox(
                                height: Dimensions.h12,
                              ),
                              Text("important_notes".tr,
                                  style: textBold().copyWith(
                                      fontSize: Dimensions.fs15,
                                      color: customColor.blue)),
                              SizedBox(
                                height: Dimensions.h8,
                              ),
                              CustomCard(
                                padding: EdgeInsets.symmetric(horizontal:Dimensions.w8 ,vertical: Dimensions.h8,),
                                borderRadius: Dimensions.r8,
                                child: Text(
                                  "Phone number updated - old number not working", // من API
                                  style: textRegular(),
                                ),
                              ),
                              SizedBox(
                                height: Dimensions.h4,
                              ),
                              CustomCard(
                                padding: EdgeInsets.symmetric(horizontal:Dimensions.w8 ,vertical: Dimensions.h8,),
                                borderRadius: Dimensions.r8,
                                child: Text(
                                    "Delivery can be made to any family member with ID", // من API
                                    style: textRegular()),
                              ),
                              SizedBox(
                                height: Dimensions.h4,
                              ),
                              CustomCard(
                                  padding: EdgeInsets.symmetric(horizontal:Dimensions.w8 ,vertical: Dimensions.h8,),
                                  borderRadius: Dimensions.r8,
                                  child: Text(
                                      "Make sure to call before you go", // من API
                                      style: textRegular())),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.h20,
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
                              width: Dimensions.w8,
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
                              width: Dimensions.w8,
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
              padding: EdgeInsets.all(16),
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
                    height: Dimensions.h16,
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
                        width: Dimensions.w12,
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