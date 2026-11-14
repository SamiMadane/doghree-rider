/// Body of update-order-status. Auth goes in the Bearer header only (D-02).
class UpdateStatusBodyModel {
  int? orderId;
  String? status;
  String? otp;
  String method = 'put';
  String? reason;

  UpdateStatusBodyModel({this.orderId, this.status, this.otp, this.reason});

  UpdateStatusBodyModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    status = json['status'];
    otp = json['otp'];
    status = json['_method'];
    reason = json['reason'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['order_id'] = orderId.toString();
    data['status'] = status!;
    data['otp'] = otp??'';
    data['_method'] = method;
    if(reason != '' && reason != null) {
      data['reason'] = reason!;
    }
    return data;
  }
}
