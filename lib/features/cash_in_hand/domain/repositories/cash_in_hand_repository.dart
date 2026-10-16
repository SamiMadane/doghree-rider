import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wefrh_rider/api/api_checker.dart';
import 'package:wefrh_rider/api/api_client.dart';
import 'package:wefrh_rider/common/models/response_model.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/wallet_payment_model.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/repositories/cash_in_hand_repository_interface.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/wallet_model.dart';


class CashInHandRepository implements CashInHandRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CashInHandRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.makeCollectedCashPaymentUri, {
      "amount": amount,
      "payment_gateway": paymentGatewayName,
      "callback": RouteHelper.success,
      "token": _getUserToken(),
    }, handleError: false);

    if (response.statusCode == 200) {
      String redirectUrl = response.body['redirect_link'];
      Get.back();
      if(GetPlatform.isWeb) {
        // html.window.open(redirectUrl,"_self");
      } else{
        Get.toNamed(RouteHelper.getPaymentRoute(redirectUrl));
      }
      responseModel = ResponseModel(true, response.body.toString());
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<List<Transactions>?> getList() async {
    List<Transactions>? transactions;
    Response response = await apiClient.getData('${AppConstants.walletPaymentListUri}?token=${_getUserToken()}');
    if(response.statusCode == 200) {
      transactions = [];
      WalletPaymentModel walletPaymentModel = WalletPaymentModel.fromJson(response.body);
      transactions.addAll(walletPaymentModel.transactions!);
    }
    return transactions;
  }

  @override
  Future<List<Transactions>?> getWalletProvidedEarningList() async {
    List<Transactions>? walletProvidedTransactions;
    Response response = await apiClient.getData('${AppConstants.walletProvidedEarningListUri}?token=${_getUserToken()}');
    if(response.statusCode == 200) {
      walletProvidedTransactions = [];
      WalletPaymentModel walletPaymentModel = WalletPaymentModel.fromJson(response.body);
      walletProvidedTransactions.addAll(walletPaymentModel.transactions!);
    }
    return walletProvidedTransactions;
  }

  @override
  Future<ResponseModel> makeWalletAdjustment() async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.makeWalletAdjustmentUri, {'token': _getUserToken()}, handleError: false);
    if(response.statusCode == 200) {
      responseModel = ResponseModel(true, 'wallet_adjustment_successfully'.tr);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<EarningReportModel?> getEarningReport({String? offset, String? type, String? startDate, String? endDate}) async {
    EarningReportModel? earningReportModel;
    Response response;

    if(startDate != null && endDate != null) {
      response = await apiClient.getData('${AppConstants.earningReportUri}?limit=10&offset=$offset&type=$type&start_date=$startDate&end_date=$endDate&token=${_getUserToken()}');
    } else {
      response = await apiClient.getData('${AppConstants.earningReportUri}?limit=10&offset=$offset&type=$type&start_date=&end_date=&token=${_getUserToken()}');
    }

    if(response.statusCode == 200) {
      earningReportModel = EarningReportModel.fromJson(response.body);
    }
    return earningReportModel;
  }

  @override
  Future<Response> downloadEarningInvoice({required int dmId}) async {
    Response response = await apiClient.getData('${AppConstants.earningReportInvoiceUri}/$dmId', handleError: false);
    return response;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
    @override
  Future<WalletModel?> getWallet() async {
    final Response response = await apiClient.getData(AppConstants.walletUri);
    if (response.statusCode == 200 && response.body is Map) {
      return WalletModel.fromJson(Map<String, dynamic>.from(response.body));
    }
    return null;
  }
    @override
  Future<ResponseModel> saveWalletAccount(
      {required int methodId,
      required Map<String, String> fields,
      bool isDefault = false}) async {
    final Response response = await apiClient.postData(
      AppConstants.walletAccountsUri,
      {
        'withdrawal_method_id': methodId,
        'fields': fields,
        'is_default': isDefault,
      },
      handleError: false,
    );
    return _walletResult(response);
  }

  @override
  Future<ResponseModel> deleteWalletAccount(int id) async {
    final Response response = await apiClient
        .deleteData('${AppConstants.walletAccountsUri}/$id', handleError: false);
    return _walletResult(response);
  }

  ResponseModel _walletResult(Response response) {
    if (response.statusCode == 401) {
      ApiChecker.checkApi(response); // انتهاء الجلسة
    }
    if (response.statusCode == 200) {
      final body = response.body;
      return ResponseModel(true, body is Map ? body['message']?.toString() : null);
    }
    return ResponseModel(false, response.statusText,
        statusCode: response.statusCode);
  }

}