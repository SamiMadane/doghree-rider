import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/payment_loading_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';

class PaymentScreen extends StatefulWidget {
  final String? redirectUrl;
  const PaymentScreen({super.key, this.redirectUrl});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  bool _isLoading = true;
  bool _canRedirect = true;
  bool _initialLoadComplete = false;

  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.redirectUrl!;
  }

  @override
  Widget build(BuildContext context) {
    pullToRefreshController ??= PullToRefreshController(
      settings: PullToRefreshSettings(
        color: ManagerColors.primaryLight,
      ),
      onRefresh: () async {
        if (GetPlatform.isAndroid) {
          webViewController?.reload();
        } else if (GetPlatform.isIOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _exitApp();
      },
      child: Scaffold(
        backgroundColor: ManagerColors.white,
        appBar: CustomAppBarWidget(
          title: 'payment'.tr,
          backGroundColor: ManagerColors.white,
          titleColor: ManagerColors.TextColorLight,
          iconColor: ManagerColors.TextColorLight,
          onBackPressed: () => _exitApp(),
        ),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                Opacity(
                  opacity: _initialLoadComplete ? 1.0 : 0.0,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(selectedUrl),
                    ),
                    pullToRefreshController: pullToRefreshController,
                    initialSettings: InAppWebViewSettings(
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      iframeAllow: "camera; microphone",
                      iframeAllowFullscreen: true,
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      useHybridComposition: true,
                      forceDark: ForceDark.OFF,
                    ),
                    onWebViewCreated: (controller) async {
                      webViewController = controller;
                      if (kDebugMode) {
                        print("WebView Created");
                      }
                    },
                    onLoadStart: (controller, url) async {
                      if (kDebugMode) {
                        print("Started: $url");
                      }
                      _redirect(url.toString());
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController?.endRefreshing();
                      if (kDebugMode) {
                        print("Stopped: $url");
                      }

                      String urlString = url.toString();
                      if (urlString.contains('checkout.stripe.com') ||
                          urlString.contains('stripe.com')) {
                        await Future.delayed(const Duration(milliseconds: 500));
                        setState(() {
                          _isLoading = false;
                          _initialLoadComplete = true;
                        });
                      }

                      _redirect(urlString);
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController?.endRefreshing();
                      }

                      if (kDebugMode) {
                        print("Progress: $progress");
                      }
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController?.endRefreshing();
                      setState(() {
                        _isLoading = false;
                        _initialLoadComplete = true;
                      });
                      if (kDebugMode) {
                        print("Error loading: $url - $message");
                      }
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      if (kDebugMode) {
                        print("Override: ${navigationAction.request.url}");
                      }
                      return NavigationActionPolicy.ALLOW;
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      if (kDebugMode) {
                        print("Console: ${consoleMessage.message}");
                      }
                    },
                  ),
                ),
                // 👇 استخدام الويدجت الخارجي
                if (_isLoading) const PaymentLoadingWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _redirect(String url) {
    if (kDebugMode) {
      print('---Redirect URL Check---: $url');
    }

    if (_canRedirect) {
      bool isSuccess =
          url.contains('${AppConstants.baseUrl}/success?flag=success') ||
              url.contains('payment/success') ||
              url.contains('success?flag=success');
      bool isFailed =
          url.contains('${AppConstants.baseUrl}/success?flag=fail') ||
              url.contains('payment/fail') ||
              url.contains('success?flag=fail');
      bool isCancel =
          url.contains('${AppConstants.baseUrl}/success?flag=cancel') ||
              url.contains('payment/cancel') ||
              url.contains('success?flag=cancel');

      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;

        if (kDebugMode) {
          print(
              'Payment Result: ${isSuccess ? "Success" : isFailed ? "Failed" : "Cancelled"}');
        }

        // 👇 الحل الأفضل مع Named Routes
        String status = isSuccess
            ? 'success'
            : isFailed
                ? 'fail'
                : 'cancel';

        Get.offNamed(
          RouteHelper.getSuccessRoute(status),
          preventDuplicates: true, // 👈 منع التكرار
        );
      }
    }
  }

  Future<bool?> _exitApp() async {
    return showCustomBottomSheet(
        closeButtonBackgroundColor: ManagerColors.white,
        sheetBackgroundColor: ManagerColors.white,
        closeIconColor: const Color(0xFF292D32),
        handleColor: const Color(0xFF6C7278),
        child: CustomConfirmationBottomSheet(
            title:
                'are_you_sure_cancel_payment'.tr,
            confirmButtonText: 'yes_cancel'.tr,
            cancelButtonText: 'no_stay'.tr,
            backgroundColor: ManagerColors.white,
            buttonColor: ManagerColors.primaryLight,
            borderColor: const Color(0xFF292D32),
            textColor: const Color(0xFF292D32),
            onConfirm: () {
              Get.back();
              Get.offNamed(
                RouteHelper.getSuccessRoute('cancel'),
                preventDuplicates: true,
              );
            }));
  }

  @override
  void dispose() {
    webViewController = null;
    super.dispose();
  }
}
