class RecordLocationBodyModel {
  String? token;
  double? longitude;
  double? latitude;
  String? location;

  RecordLocationBodyModel({this.token, this.longitude, this.latitude, this.location});

  RecordLocationBodyModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    longitude = json['longitude']?.toDouble();
    latitude = json['latitude']?.toDouble();
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Only the WebSocket path sets a token (it cannot carry a header).
    // The HTTP path uses the Bearer header and sends no token field.
    if (token != null) data['token'] = token;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['location'] = location;
    return data;
  }
}