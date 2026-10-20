// حماية الخريطة من الشاشة البيضاء.
// ملف الخريطة يغطي غزة فقط. أي نقطة خارجها = خريطة فارغة بلا أي خطأ.

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// حدود ملف الخريطة: جنوب-غرب / شمال-شرق
final LatLngBounds gazaBounds = LatLngBounds(
  const LatLng(31.19, 34.18),
  const LatLng(31.62, 34.60),
);

/// هل هذه النقطة موقع حقيقي داخل غزة؟
bool isUsablePoint(double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  if (!lat.isFinite || !lng.isFinite) return false;
  if (lat.abs() > 90 || lng.abs() > 180) return false;
  // 0,0 تعني «لا يوجد موقع» وليست مكاناً (هي في المحيط الأطلسي)
  if (lat.abs() < 0.0001 && lng.abs() < 0.0001) return false;
  return gazaBounds.contains(LatLng(lat, lng));
}

/// يقرأ إحداثيات قادمة من الـ API كنص أو رقم.
LatLng? parsePoint(Object? lat, Object? lng) {
  final la = double.tryParse('${lat ?? ''}');
  final ln = double.tryParse('${lng ?? ''}');
  return isUsablePoint(la, ln) ? LatLng(la!, ln!) : null;
}

/// نقطة الفتح: النقطة المخزّنة إن كانت صالحة، وإلا مركز السيرفر.
LatLng safeCentre(LatLng? stored, LatLng fallback) {
  if (stored != null && isUsablePoint(stored.latitude, stored.longitude)) {
    return stored;
  }
  return fallback;
}

/// يحذف النقاط الخاطئة قبل fitCamera — مندوب واحد بلا موقع يكفي ليبعد الخريطة لنصف الكرة الأرضية.
List<LatLng> usablePoints(Iterable<LatLng> points) => points
    .where((p) => isUsablePoint(p.latitude, p.longitude))
    .toList();
